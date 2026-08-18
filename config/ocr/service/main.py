#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
RapidOCR-ONNX 局域网 OCR 服务 (PP-OCRv6: tiny / small / medium)

功能:
  - 三档模型常驻内存, 请求参数 ?model=tiny|small|medium 切换 (默认 medium)
  - 共享 token 鉴权: X-OCR-Token 请求头 或 ?token= 查询参数
  - 双入参: multipart 文件上传 或 JSON base64
  - 输出: 默认 JSON (box/text/score/elapsed_ms/model), ?format=text 返回纯文本
  - 资源治理: 并发信号量限流 + RSS 内存软/硬闸门 (超硬限自杀, 由 launchd 拉起)
  - 禁 URL 取图 (无 SSRF 面), 上传大小/图片尺寸上限

环境变量:
  OCR_TOKEN        鉴权 token (必填)
  OCR_HOST         监听地址, 默认 0.0.0.0
  OCR_PORT         监听端口, 默认 8000
  OCR_CONCURRENCY  并发推理上限, 默认 2
  OCR_MEM_SOFT_MB  RSS 软限, 超过拒绝新请求 (503), 默认 1536
                   (medium 工作内存实测 ~1.25GB, 软限须高于此)
  OCR_MEM_HARD_MB  RSS 硬限, 超过自杀退出 (默认 2048), launchd KeepAlive 拉起

运行: conda run -n rapidocr python main.py
"""
import asyncio
import base64
import io
import os
import secrets
import sys
from pathlib import Path

import numpy as np
import psutil
import uvicorn
from fastapi import FastAPI, File, HTTPException, Request, UploadFile
from fastapi.responses import JSONResponse, PlainTextResponse
from fastapi.staticfiles import StaticFiles
from PIL import Image
from starlette.concurrency import run_in_threadpool

from rapidocr import RapidOCR

# ---------------------------------------------------------------- 配置
BASE_DIR = Path(__file__).resolve().parent
MODELS_DIR = BASE_DIR.parent / "models"
STATIC_DIR = BASE_DIR / "static"

OCR_TOKEN = os.environ.get("OCR_TOKEN", "")
if not OCR_TOKEN:
    print("FATAL: OCR_TOKEN 未设置, 服务拒绝启动。请在环境变量中配置鉴权 token。")
    sys.exit(1)

HOST = os.environ.get("OCR_HOST", "0.0.0.0")
PORT = int(os.environ.get("OCR_PORT", "8000"))
CONCURRENCY = int(os.environ.get("OCR_CONCURRENCY", "2"))
MEM_SOFT_MB = int(os.environ.get("OCR_MEM_SOFT_MB", "1536"))
MEM_HARD_MB = int(os.environ.get("OCR_MEM_HARD_MB", "2048"))

MAX_UPLOAD_BYTES = 20 * 1024 * 1024   # 20 MB
MAX_IMAGE_SIDE = 8192                 # 最长边像素上限

TIERS = ("tiny", "small", "medium")
DEFAULT_TIER = "medium"

_proc = psutil.Process()


# ---------------------------------------------------------------- 模型引擎 (三档常驻)
def _build_engine(tier: str) -> RapidOCR:
    """按档位构造 RapidOCR 引擎 (显式指定模型路径, 常驻内存)。"""
    params = {
        "Global.model_root_dir": str(MODELS_DIR),
        "Global.use_det": True,
        "Global.use_cls": True,
        "Global.use_rec": True,
        # 限制每会话线程数, 配合并发信号量避免 CPU 过度竞争
        "Det.intra_op_num_threads": 4,
        "Rec.intra_op_num_threads": 4,
        "Det.model_path": str(MODELS_DIR / f"PP-OCRv6_det_{tier}.onnx"),
        "Cls.model_path": str(MODELS_DIR / "ch_ppocr_mobile_v2.0_cls_mobile.onnx"),
        "Rec.model_path": str(MODELS_DIR / f"PP-OCRv6_rec_{tier}.onnx"),
    }
    return RapidOCR(params=params)


# 启动即预热全部三档 (决策: 常驻, 换档零延迟)
print("加载三档模型 (tiny/small/medium)...")
ENGINES: dict[str, RapidOCR] = {tier: _build_engine(tier) for tier in TIERS}
print("模型加载完成: " + ", ".join(TIERS))

app = FastAPI(title="RapidOCR-ONNX LAN Service", version="1.0.0")

_sem = asyncio.Semaphore(CONCURRENCY)


# ---------------------------------------------------------------- 资源闸门
def _rss_mb() -> float:
    return _proc.memory_info().rss / 1024 / 1024


def check_memory_gate() -> None:
    """RSS 内存闸门: 硬限自杀(launchd 拉起自愈), 软限拒绝新请求。"""
    rss = _rss_mb()
    if rss > MEM_HARD_MB:
        print(f"FATAL: RSS={rss:.0f}MB 超过硬限 {MEM_HARD_MB}MB, 主动退出等待 launchd 拉起")
        os._exit(1)
    if rss > MEM_SOFT_MB:
        raise HTTPException(status_code=503, detail=f"服务繁忙: 内存占用 {rss:.0f}MB 超软限")


# ---------------------------------------------------------------- 鉴权
def require_token(request: Request) -> None:
    token = request.headers.get("X-OCR-Token") or request.query_params.get("token")
    if not token or not secrets.compare_digest(token, OCR_TOKEN):
        raise HTTPException(status_code=401, detail="无效或缺失 token (X-OCR-Token 头 / ?token=)")


# ---------------------------------------------------------------- 图片解析
def _decode_image(data: bytes) -> np.ndarray:
    if len(data) > MAX_UPLOAD_BYTES:
        raise HTTPException(status_code=413, detail=f"文件超过 {MAX_UPLOAD_BYTES // (1024*1024)}MB 上限")
    try:
        img = Image.open(io.BytesIO(data))
        img.load()
    except Exception:
        raise HTTPException(status_code=400, detail="无法解析的图片文件")
    w, h = img.size
    if max(w, h) > MAX_IMAGE_SIDE:
        raise HTTPException(status_code=400, detail=f"图片最长边 {max(w, h)}px 超过上限 {MAX_IMAGE_SIDE}px")
    return np.array(img.convert("RGB"))


def _boxes_to_list(boxes) -> list:
    if boxes is None:
        return []
    return [[[int(round(float(p[0]))), int(round(float(p[1])))] for p in box] for box in boxes]


def _run_ocr(engine: RapidOCR, img: np.ndarray) -> dict:
    out = engine(img)
    return {
        "boxes": _boxes_to_list(out.boxes),
        "txts": list(out.txts) if out.txts else [],
        "scores": list(out.scores) if out.scores else [],
        "elapsed_ms": out.elapse * 1000.0,
    }


async def _infer(tier: str, img: np.ndarray) -> dict:
    # 并发闸门: 非阻塞获取, 满载立即 429 (不堆积请求, 守住资源上限)
    try:
        await asyncio.wait_for(_sem.acquire(), timeout=0.05)
    except asyncio.TimeoutError:
        raise HTTPException(status_code=429, detail="服务繁忙: 并发推理已达上限, 请稍后再试")
    try:
        return await run_in_threadpool(_run_ocr, ENGINES[tier], img)
    finally:
        _sem.release()


# ---------------------------------------------------------------- 路由
@app.get("/health")
def health():
    return {"status": "ok", "models": list(TIERS), "rss_mb": round(_rss_mb(), 1)}


@app.post("/ocr")
async def ocr(
    request: Request,
    model: str = DEFAULT_TIER,
    format: str = "json",
    file: UploadFile | None = File(default=None),
):
    """OCR 接口。

    - 鉴权: X-OCR-Token 头 或 ?token=
    - 入参: multipart 字段 file 上传 或 JSON {"image": "<base64>", "model": "..."}
    - 出参: ?format=json (默认) 结构化 JSON; ?format=text 纯文本
    """
    require_token(request)
    tier = model if model in TIERS else DEFAULT_TIER
    if model not in TIERS:
        raise HTTPException(status_code=400, detail=f"model 必须是 {TIERS} 之一")

    check_memory_gate()

    # 双入参解析
    if file is not None:
        data = await file.read()
    else:
        try:
            body = await request.json()
        except Exception:
            raise HTTPException(status_code=400, detail="请用 multipart 的 file 字段上传, 或 JSON 传 base64 的 image 字段")
        data_b64 = body.get("image")
        if not data_b64:
            raise HTTPException(status_code=400, detail="JSON 请求需要 image 字段 (base64 字符串)")
        if "model" in body and body["model"] in TIERS:
            tier = body["model"]
        try:
            data = base64.b64decode(data_b64, validate=True)
        except Exception:
            raise HTTPException(status_code=400, detail="image 字段不是合法的 base64")

    img = _decode_image(data)
    res = await _infer(tier, img)

    if format == "text":
        return PlainTextResponse("\n".join(res["txts"]))
    if format != "json":
        raise HTTPException(status_code=400, detail="format 只能是 json 或 text")

    return JSONResponse({
        "model": tier,
        "elapsed_ms": round(res["elapsed_ms"], 1),
        "results": [
            {"box": b, "text": t, "score": round(s, 4)}
            for b, t, s in zip(res["boxes"], res["txts"], res["scores"])
        ],
    })


# 网页 UI
app.mount("/", StaticFiles(directory=str(STATIC_DIR), html=True), name="ui")


if __name__ == "__main__":
    uvicorn.run(app, host=HOST, port=PORT, log_level="info")
