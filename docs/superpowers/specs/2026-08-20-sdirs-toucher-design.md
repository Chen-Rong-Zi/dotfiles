# sdirs-toucher 设计文档

日期：2026-08-20
状态：已批准（设计对话确认）

## 背景与目标

`~/.sdirs` 是用户需要保留的一个文件（当前为空）。用户希望有一个常驻进程**持有一个 `~/.sdirs` 的文件句柄**，以**可配置的间隔**持续把该文件的 **mtime 刷成当前时间**，使其不被按 mtime 清理的机制视为过期/删除。除此之外**不修改文件内容、不修改 atime、不访问或修改其他任何文件**。

## 核心约束（来自需求澄清）

- 只修改 `~/.sdirs` 这一个文件的 mtime，不改内容、不碰其他文件。
- 更新间隔可配置（"更新速度可以指定"）。
- 采用 Python 常驻脚本实现，持 fd 句柄（用户已选定，弃用 Bash+touch 与 launchd 方案）。

## 架构

单文件脚本，零第三方依赖，约 50 行，位于 `~/.dotfiles/local/bin/sdirs-toucher.py`，经符号链接暴露到 `~/.local/bin/sdirs-toucher.py`（沿用该目录既有的 dotfiles 管理模式）。

### CLI

| 参数 | 说明 | 默认 |
|------|------|------|
| `-i, --interval` | 刷 mtime 的间隔秒数 | `300` |
| `-p, --path` | 目标文件路径 | `~/.sdirs` |
| `-q, --quiet` | 静默模式，不输出 heartbeat | 关闭 |

### 主循环

1. `open(path, 'a')` → 文件不存在则创建，保持 fd 句柄打开。
2. 每 tick：
   - `fstat(fd)` 取当前 `st_atime_ns`；
   - `os.utime(fd, ns=(st_atime_ns, time.time_ns()))` —— 仅刷新 mtime，保留 atime 与内容；
   - `sleep(interval)`。
3. 自愈：每次醒来检查 `os.path.exists(path)`，若文件被清理机制删除，则关闭旧 fd、重新 `open(path, 'a')` 重建并继续（否则 futimens 只作用于已 unlink 的孤儿 inode，保活失效）。

### 信号与退出

- `SIGTERM` / `SIGINT` → 关闭 fd，干净退出（码 0）。
- 打开/创建失败 → stderr 报错，退出（码 1）。
- 运行中 `os.utime` 失败 → 记日志到 stderr，不退出，下个周期重试。

### 输出

- 默认每 tick 向 stdout 打一行 heartbeat（时间戳 + 间隔信息）。
- `-q` 时静默。
- 一切错误走 stderr。

## 数据流

```
进程持 fd ──每 interval 秒 futimens(mtime=now)──> ~/.sdirs mtime 保持新鲜
```

## 错误处理汇总

| 场景 | 行为 |
|------|------|
| 文件无法打开/创建 | stderr 报错，退出码 1 |
| 运行中 utime 失败 | 记日志，不退出，下周期重试 |
| 运行中文件被删除 | 检测到后重新创建并打开，继续 |
| 收到 SIGTERM/SIGINT | 关 fd，退出码 0 |

## 测试（手工验证）

1. `sdirs-toucher.py -i 1` 跑数秒，`stat -f "%m %a %z" ~/.sdirs`：mtime 每秒变化，atime 与大小不变。
2. 运行中 `rm ~/.sdirs`：脚本自动重建文件并继续。
3. `Ctrl-C` / `kill -TERM`：干净退出。
4. `sdirs-toucher.py -q -i 1`：无 stdout 输出。

## 非目标（YAGNI）

- 不写入目录快照内容。
- 不做 launchd 包装（后续需要时另行设计）。
- 不监控除目标文件外的任何路径。
