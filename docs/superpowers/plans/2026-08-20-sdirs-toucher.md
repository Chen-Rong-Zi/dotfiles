# sdirs-toucher 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现一个零依赖的常驻 Python 脚本，持 `~/.sdirs` 的 fd 句柄并以可配置间隔只刷新该文件的 mtime。

**Architecture:** 单文件脚本 `~/.dotfiles/local/bin/sdirs-toucher.py`：argparse 解析 `-i/--interval`、`-p/--path`、`-q/--quiet`；`open()` 持 fd；主循环每 tick 用 `os.utime(fd, ns=(atime_ns, now_ns))` 只刷 mtime；运行中若路径被删则重建续跑；SIGTERM/SIGINT 干净退出。经符号链接暴露到 `~/.local/bin/`。

**Tech Stack:** Python 3（仅标准库：argparse / os / signal / sys / time），macOS。

**设计文档:** `docs/superpowers/specs/2026-08-20-sdirs-toucher-design.md`

---

### Task 1: 编写脚本并落位

**Files:**
- Create: `~/.dotfiles/local/bin/sdirs-toucher.py`
- Symlink: `~/.local/bin/sdirs-toucher.py` → `~/.dotfiles/local/bin/sdirs-toucher.py`

- [ ] **Step 1: 写入脚本**

创建 `~/.dotfiles/local/bin/sdirs-toucher.py`，内容如下（零依赖，仅标准库）：

```python
#!/usr/bin/env python3
"""sdirs-toucher: keep a file's mtime fresh via a held open handle.

Holds an open file descriptor on a target file (default ~/.sdirs) and, at a
configurable interval, updates ONLY the file's mtime to the current time.
Content and atime are left untouched; no other files are accessed.
"""

import argparse
import os
import signal
import sys
import time


def parse_args(argv):
    p = argparse.ArgumentParser(
        description="Keep a file's mtime fresh via a held file handle."
    )
    p.add_argument("-i", "--interval", type=int, default=300,
                   help="seconds between mtime updates (default: 300)")
    p.add_argument("-p", "--path", default="~/.sdirs",
                   help="target file path (default: ~/.sdirs)")
    p.add_argument("-q", "--quiet", action="store_true",
                   help="suppress heartbeat output")
    return p.parse_args(argv)


def open_target(path):
    """Open (creating if needed) the target file; return fd."""
    return os.open(path, os.O_CREAT | os.O_WRONLY, 0o644)


def touch_mtime(fd):
    """Set mtime to now, preserving atime. Returns True on success."""
    try:
        st = os.fstat(fd)
        os.utime(fd, ns=(st.st_atime_ns, time.time_ns()))
        return True
    except OSError as e:
        print(f"sdirs-toucher: utime failed: {e}", file=sys.stderr)
        return False


def main(argv=None):
    args = parse_args(argv)
    path = os.path.expanduser(args.path)

    if args.interval <= 0:
        print("sdirs-toucher: interval must be positive", file=sys.stderr)
        return 2

    try:
        fd = open_target(path)
    except OSError as e:
        print(f"sdirs-toucher: cannot open {path}: {e}", file=sys.stderr)
        return 1

    def _shutdown(signum, frame):
        os.close(fd)
        sys.exit(0)

    signal.signal(signal.SIGTERM, _shutdown)
    signal.signal(signal.SIGINT, _shutdown)

    if not args.quiet:
        print(f"sdirs-toucher: holding {path}, touching mtime every {args.interval}s",
              flush=True)

    while True:
        touch_mtime(fd)
        if not args.quiet:
            print(f"sdirs-toucher: tick {time.strftime('%H:%M:%S')}", flush=True)
        time.sleep(args.interval)
        # Self-heal: if the path was removed, re-open to keep it alive.
        if not os.path.exists(path):
            try:
                os.close(fd)
                fd = open_target(path)
                print(f"sdirs-toucher: {path} was removed; recreated", file=sys.stderr)
            except OSError as e:
                print(f"sdirs-toucher: cannot recreate {path}: {e}", file=sys.stderr)
                return 1


if __name__ == "__main__":
    sys.exit(main())
```

- [ ] **Step 2: 设置权限并链接**

```bash
chmod +x ~/.dotfiles/local/bin/sdirs-toucher.py
ln -sf ~/.dotfiles/local/bin/sdirs-toucher.py ~/.local/bin/sdirs-toucher.py
```
Expected: `~/.local/bin/sdirs-toucher.py` 存在且是符号链接。

- [ ] **Step 3: 提交**

```bash
git -C ~/.dotfiles add local/bin/sdirs-toucher.py
git -C ~/.dotfiles commit -m "feat: add sdirs-toucher keepalive for ~/.sdirs mtime"
```
Expected: 提交成功，`1 file changed, ~80 insertions(+)`。

---

### Task 2: 手工验证四项

**Files:**
- 无新文件；运行验证命令

- [ ] **Step 1: mtime 刷新且 atime/内容不变**

```bash
sdirs-toucher.py -i 1 & TPID=$!
sleep 2
stat -f "mtime=%m atime=%a size=%z" ~/.sdirs; sleep 2
stat -f "mtime=%m atime=%a size=%z" ~/.sdirs
kill $TPID
```
Expected: 两次输出的 `mtime=` 不同（间隔约 1s），`atime=` 与 `size=0` 保持不变。

- [ ] **Step 2: 运行中删除自动重建**

```bash
sdirs-toucher.py -i 1 & TPID=$!
sleep 1
rm ~/.sdirs
sleep 2
ls -la ~/.sdirs; kill $TPID
```
Expected: 删除后约 1 秒内 `~/.sdirs` 重新出现（size=0），stderr 出现 `was removed; recreated`。

- [ ] **Step 3: SIGTERM 干净退出**

```bash
sdirs-toucher.py -i 300 & TPID=$!
sleep 1
kill -TERM $TPID; wait $TPID; echo "exit=$?"
```
Expected: `exit=0`。

- [ ] **Step 4: -q 静默**

```bash
sdirs-toucher.py -q -i 1 > /tmp/sdirs-q.log 2>&1 & TPID=$!
sleep 2; kill -TERM $TPID; wait $TPID; echo "exit=$?"
wc -c < /tmp/sdirs-q.log
```
Expected: `exit=0`，日志字节数为 `0`（无任何 stdout/stderr 输出）。

- [ ] **Step 5: 最终提交（如有修正）**

若验证中发现问题并修改了脚本：
```bash
git -C ~/.dotfiles add local/bin/sdirs-toucher.py
git -C ~/.dotfiles commit -m "fix: sdirs-toucher verification fixes"
```
若无修改则跳过此步。

---

### Task 3: 清理

- [ ] **Step 1: 确认无残留进程**

```bash
pgrep -fl sdirs-toucher || echo "no stray processes"
rm -f /tmp/sdirs-q.log
```
Expected: 无残留（或 `no stray processes`），临时日志已删除。

- [ ] **Step 2: 计划文档落位（可选）**

本计划已存在于 `docs/superpowers/plans/`；如需入库：`git -C ~/.dotfiles add docs/superpowers/plans/2026-08-20-sdirs-toucher.md && git -C ~/.dotfiles commit -m "docs: sdirs-toucher implementation plan"`。
