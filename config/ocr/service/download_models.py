#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
下载 RapidOCR-ONNX (PP-OCRv6) tiny/small/medium 三档模型到 models/ 目录。
通过 rapidocr 包自身的模型解析 + SHA256 校验下载，避免手写 URL/哈希出错。
用法: conda run -n rapidocr python download_models.py
"""
from pathlib import Path
import sys

from rapidocr.inference_engine.base import FileInfo
from rapidocr.utils.download_models import download_task
from rapidocr.utils.typings import (
    EngineType,
    LangCls,
    LangDet,
    LangRec,
    ModelType,
    OCRVersion,
    TaskType,
)

MODELS_DIR = Path(__file__).resolve().parent.parent / "models"

# 三档: (档位名, det ModelType, rec ModelType)
TIERS = [
    ("tiny", ModelType.TINY, ModelType.TINY),
    ("small", ModelType.SMALL, ModelType.SMALL),
    ("medium", ModelType.MEDIUM, ModelType.MEDIUM),
]


def download_tier(cache_dir: Path, tier: str, det_mt: ModelType, rec_mt: ModelType) -> None:
    print(f"\n=== 下载档位: {tier} ===")
    # det (v6 多语言模型, 语言参数为 ch)
    download_task(
        cache_dir,
        FileInfo(EngineType.ONNXRUNTIME, OCRVersion.PPOCRV6, TaskType.DET, LangDet.CH, det_mt),
    )
    # rec + 字典
    download_task(
        cache_dir,
        FileInfo(EngineType.ONNXRUNTIME, OCRVersion.PPOCRV6, TaskType.REC, LangRec.CH, rec_mt),
    )
    print(f"[OK] {tier} 完成")


def main() -> None:
    MODELS_DIR.mkdir(parents=True, exist_ok=True)
    for tier, det_mt, rec_mt in TIERS:
        download_tier(MODELS_DIR, tier, det_mt, rec_mt)

    # cls: PP-OCRv6 无 cls，方向分类复用 v4 cls mobile（所有档位共享一份）
    print("\n=== 下载 cls (v4 mobile, 共享) ===")
    download_task(
        MODELS_DIR,
        FileInfo(EngineType.ONNXRUNTIME, OCRVersion.PPOCRV4, TaskType.CLS, LangCls.CH, ModelType.MOBILE),
    )
    print("[OK] cls 完成")

    print("\n=== 下载完成, 文件清单 ===")
    for f in sorted(MODELS_DIR.iterdir()):
        size_mb = f.stat().st_size / 1024 / 1024
        print(f"  {f.name:60s} {size_mb:8.2f} MB")


if __name__ == "__main__":
    sys.exit(main())
