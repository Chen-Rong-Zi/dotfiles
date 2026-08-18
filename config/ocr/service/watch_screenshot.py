#!/usr/bin/env python3
# -*- encoding: utf-8 -*-
"""
macOS 截图监听器 (launchd 常驻, com.local.ocrwatch)

- 用 kqueue (select.kqueue + KQ_FILTER_VNODE) 注册 ~/Pictures/screenshot 目录事件
- 捕获到目录变化事件 → 扫描目录找新截图 → 后台启动 ocr_flow.py (AppleScript 弹窗)
- 首次启动建立基线, 不处理已有历史截图; 之后仅处理新增文件

说明: kqueue 事件只通知"目录发生了写入/重命名/扩展", 不携带文件名,
因此事件触发后仍需扫描目录确认新文件 —— 但响应从轮询 1.5s 降为毫秒级。

截图路径用 base64 编码传递, 规避文件名中的空格与引号。
"""
import base64
import os
import select
import subprocess
import sys
import time
from pathlib import Path

SCREENSHOT_DIR = Path.home() / "Pictures" / "screenshot"
IMAGE_EXTS = {".png", ".jpg", ".jpeg", ".gif", ".tiff", ".webp"}
SCRIPT_DIR = Path(__file__).resolve().parent
PY = "/opt/homebrew/Caskroom/miniconda/base/envs/rapidocr/bin/python"
FRESH_WINDOW = 60  # 秒: 只把最近 60s 内写入的新文件当"新截图"
# kqueue 监听目录的哪些变化
NOTE_FLAGS = select.KQ_NOTE_WRITE | select.KQ_NOTE_RENAME | select.KQ_NOTE_EXTEND | select.KQ_NOTE_DELETE
IDLE_TIMEOUT = 3  # 秒: kqueue 无事件时最长阻塞, 用于周期性兜底扫描

# 事件位 → 名称 (macOS kqueue vnode)
NOTE_NAMES = {
    select.KQ_NOTE_WRITE: "WRITE",
    select.KQ_NOTE_EXTEND: "EXTEND",
    select.KQ_NOTE_RENAME: "RENAME",
    select.KQ_NOTE_DELETE: "DELETE",
    select.KQ_NOTE_ATTRIB: "ATTRIB",
    select.KQ_NOTE_LINK: "LINK",
    select.KQ_NOTE_REVOKE: "REVOKE",
}


def fmt_flags(fflags: int) -> str:
    names = [n for bit, n in NOTE_NAMES.items() if fflags & bit]
    return "+".join(names) if names else f"0x{fflags:x}"


def scan_new(seen: set[str]) -> None:
    """扫描目录, 对每个新截图启动 ocr_flow.py。

    跳过点开头的隐藏/临时文件 (macOS 截图先写 .截屏*.png 临时文件再落盘为正式名,
    处理临时文件会导致 ocr_flow 检查文件不存在时报错)。
    """
    for p in SCREENSHOT_DIR.iterdir():
        if not p.is_file():
            continue
        if p.name.startswith("."):
            continue  # 临时/隐藏文件 (如 .截屏...png), 等正式文件名
        if p.suffix.lower() not in IMAGE_EXTS:
            continue
        if p.name in seen:
            continue
        try:
            if time.time() - p.stat().st_mtime > FRESH_WINDOW:
                continue  # 陈旧文件(非本次新增), 跳过
        except OSError:
            continue
        seen.add(p.name)
        b64 = base64.b64encode(str(p).encode()).decode()
        # 后台启动弹窗流程, 不阻塞监听循环
        subprocess.Popen(
            [PY, str(SCRIPT_DIR / "ocr_flow.py"), b64],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
        print(f"[watch] new screenshot -> {p.name}", flush=True)


def main() -> int:
    os.makedirs(SCREENSHOT_DIR, exist_ok=True)
    seen: set[str] = set()
    # 首次启动: 基线 = 当前已存在的图片文件, 不处理
    for p in SCREENSHOT_DIR.iterdir():
        if p.is_file() and p.suffix.lower() in IMAGE_EXTS:
            seen.add(p.name)
    print(f"[watch] start watching {SCREENSHOT_DIR} (kqueue, baseline {len(seen)} files)", flush=True)

    # 打开目录并注册 kqueue vnode 事件
    fd = os.open(SCREENSHOT_DIR, os.O_RDONLY)
    kq = select.kqueue()
    try:
        kq.control([select.kevent(
            fd, filter=select.KQ_FILTER_VNODE,
            flags=select.KQ_EV_ADD | select.KQ_EV_ENABLE | select.KQ_EV_CLEAR,
            fflags=NOTE_FLAGS,
        )], 0)
    except OSError as e:
        print(f"[watch] kqueue 注册失败: {e}", file=sys.stderr, flush=True)
        return 1

    while True:
        try:
            # 阻塞等待目录事件; 超时后兜底扫描(防漏)
            events = kq.control(None, 16, IDLE_TIMEOUT)
            if events:
                for e in events:
                    print(f"[watch] event: filter={e.filter} flags={fmt_flags(e.fflags)}", flush=True)
                scan_new(seen)
        except (KeyboardInterrupt, SystemExit):
            break
        except Exception as e:
            print(f"[watch] error: {e}", file=sys.stderr, flush=True)

    os.close(fd)
    return 0


if __name__ == "__main__":
    sys.exit(main())
