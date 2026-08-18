#!/usr/bin/env python3
# -*- encoding: utf-8 -*-
"""
AppleScript 弹窗方案: 截图 OCR 交互流程

替代 terminal-notifier (macOS 26 对第三方 CLI 横幅+回调组合不友好)。

流程:
  1. 弹窗① (AppleScript) 询问是否开始 OCR, 显示截图缩略图 (按钮: 取消 / 开始 OCR)
  2. 确认后调用本地 /ocr?model=tiny&format=text
  3. 自动写入 /tmp/ocr_latest.txt 并 pbcopy 复制到剪贴板
  4. 横幅通知 (display notification) 告知完成

入参: 截图路径的 base64 编码 (由 watch_screenshot.py 传入)
"""
import base64
import subprocess
import sys
import time
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
OCR_URL = "http://127.0.0.1:8000/ocr?model=tiny&format=text"
PLIST = Path.home() / "Library" / "LaunchAgents" / "com.local.rapidocr.plist"
RESULT_FILE = Path("/tmp/ocr_latest.txt")


def as_literal(s: str) -> str:
    """把 Python 字符串安全转为 AppleScript 双引号字符串字面量。

    换行直接以真实换行嵌入 (AppleScript 字符串字面量支持多行),
    避免 "& linefeed &" 拼接表达式与 with title/sound name 组合时语法解析失败 (-2741)。
    """
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def _run_osascript(script: str, timeout: float) -> subprocess.CompletedProcess | None:
    """把 AppleScript 写入临时 .scpt 文件再执行。

    避免 osascript -e 内联中文/emoji 后跟 sound name 时的词法解析 bug (-2741)。
    文件方式已实测对中文+emoji+换行+sound 全部兼容。
    """
    import tempfile
    try:
        with tempfile.NamedTemporaryFile(mode="w", suffix=".scpt", encoding="utf-8", delete=False) as f:
            f.write(script)
            tmp = f.name
        return subprocess.run(
            ["osascript", tmp], capture_output=True, text=True, timeout=timeout,
        )
    except subprocess.TimeoutExpired:
        return None
    finally:
        try:
            Path(tmp).unlink()
        except (NameError, OSError):
            pass


def dialog(title: str, msg: str, buttons: list, default: str, icon_path: str | None = None) -> str | None:
    """调用 osascript display dialog, 返回点击的按钮名; 取消/ESC 返回 None。

    icon_path: 若提供, 以截图缩略图作为对话框图标 (POSIX file 引用)。
    """
    btn_list = ", ".join(f'"{b}"' for b in buttons)
    icon_clause = f" with icon (POSIX file {as_literal(icon_path)})" if icon_path else " with icon note"
    script = (
        f"display dialog {as_literal(msg)} buttons {{{btn_list}}} "
        f"default button {as_literal(default)} with title {as_literal(title)}{icon_clause}"
    )
    out = _run_osascript(script, timeout=600)
    if out is None or out.returncode != 0:
        return None  # 超时 / 用户按 ESC / 关闭窗口
    # 输出形如: button returned:开始 OCR
    return out.stdout.split("button returned:", 1)[-1].strip() if "button returned:" in out.stdout else None


def notify(title: str, message: str) -> None:
    """横幅通知 (osascript display notification, 通过临时 .scpt 文件执行)。"""
    script = (
        f"display notification {as_literal(message)} "
        f"with title {as_literal(title)} sound name \"Glass\""
    )
    _run_osascript(script, timeout=30)


def get_token() -> str:
    try:
        out = subprocess.run(
            ["/usr/libexec/PlistBuddy", "-c", "Print :EnvironmentVariables:OCR_TOKEN", str(PLIST)],
            capture_output=True, text=True, timeout=5,
        )
        return out.stdout.strip()
    except Exception:
        return ""


def run_ocr(img_path: str) -> str:
    """调用本地 OCR 服务, 返回识别文本(纯文本格式)。"""
    token = get_token()
    if not token:
        raise RuntimeError("无法从 plist 读取 OCR_TOKEN")
    r = subprocess.run(
        ["curl", "-s", "-m", "60", "-X", "POST", OCR_URL,
         "-H", f"X-OCR-Token: {token}", "-F", f"file=@{img_path}"],
        capture_output=True, text=True, timeout=90,
    )
    return r.stdout.strip()


def main() -> int:
    if len(sys.argv) < 2:
        notify("OCR", "缺少截图路径参数")
        return 1
    try:
        img_path = base64.b64decode(sys.argv[1]).decode()
    except Exception:
        img_path = sys.argv[1]

    # 文件可能刚落盘, 短暂等待避免竞态 (最多 ~1.5s)
    p = Path(img_path)
    for _ in range(10):
        if p.is_file() and p.stat().st_size > 0:
            break
        time.sleep(0.15)
    if not p.is_file():
        notify("OCR", f"文件不存在: {img_path}")
        return 1

    # 弹窗① 询问 + 显示缩略图
    name = Path(img_path).name
    choice = dialog(
        "📄 截图 OCR",
        f"检测到新截图:\n{name}\n\n开始 OCR 识别?",
        ["取消", "开始 OCR"], "开始 OCR",
        icon_path=img_path,
    )
    if choice != "开始 OCR":
        return 0  # 用户取消

    # 执行 OCR
    try:
        text = run_ocr(img_path)
    except Exception as e:
        notify("OCR 失败", f"识别出错: {e}")
        return 1

    # 写文件 + 复制到剪贴板
    RESULT_FILE.write_text(text, encoding="utf-8")
    subprocess.run(["pbcopy"], input=text, text=True)

    # 横幅通知完成: 标题放"已复制", 消息主体放识别内容(截断)
    NOTIFY_BODY_CHARS = 200
    if text:
        body = text[:NOTIFY_BODY_CHARS]
        if len(text) > NOTIFY_BODY_CHARS:
            body += " …"
        notify(f"✅ OCR 完成 · 已复制到剪贴板 ({len(text)} 字)", body)
    else:
        notify("✅ OCR 完成", f"{name}\n未识别到文本")
    return 0


if __name__ == "__main__":
    sys.exit(main())
