# RunMode 改造：CommandRunner 统一架构设计

日期：2026-08-07
状态：已确认（用户批准架构）

## 背景与目标

现有 `vim/functions/mode.vim` 中有四个 mode（`RunMode`、`DebugMode`（RunMode.Debug）、`GrepMode`、`MypyMode`），各自实现"在 term/job 中执行命令并将输出加入 quickfix"的逻辑，存在大量重复代码：

- `ModeInit`（保存快捷键、初始化模式）
- `ModeExit`（恢复快捷键、清理 job/term/buffer）
- `Copen`（打开 quickfix 窗口）
- `Cnext`/`Cprev`（quickfix 导航）
- 输出处理（job callback → `caddexpr`，或 term + 错误文件 → quickfix）

目标：

1. **抽取可复用的 `CommandRunner` 基类**，统一实现"在 term/job 中执行命令并将输出加入 quickfix"的核心功能。
2. 四个 mode 全部继承 `CommandRunner`，只保留各自的特有配置与行为。
3. 提供类似 `:Grep` 的 `:Run` 自定义命令：允许用户传自定义运行命令，无传参时默认使用 `"io"`。
4. 保留所有现有功能：`ModeManager` 的 tab 管理、`ExitMode` 分发、Mypy 文件监听、Grep 的 operator 模式、Run 的错误文件处理。

## 架构

```
Mode（基类：mark 标记、窗口焦点）
  └── CommandRunner（基类：term/job 执行 + quickfix 输出 + 快捷键管理）
        ├── RunMode     （term 模式，默认 io -m -eq %）
        ├── DebugMode   （job 模式，默认 &makeprg）
        ├── GrepMode    （job 模式，默认 rg）
        └── MypyMode    （job + timer 模式，默认 dmypy check %）
```

## CommandRunner 基类设计

### 字段

```
# 配置
run_mode: string        # 'term' | 'job'
cmd_template: string    # 命令模板，'%' = 当前文件 %:p
title: string           # quickfix 标题

# 状态
job: job                # job 句柄（job 模式）
term_nr: number         # 终端 buffer（term 模式）
timer_id: number        # Mypy 文件监听定时器
filepath: string        # 当前文件路径
mtime: number           # 文件修改时间戳
open_term: bool         # 是否打开终端/qf
loaded_buf_nr: list<number>  # 缓冲清理记录（Grep 用）
maping_ctrl_p: dict<any>     # 快捷键备份
maping_ctrl_n: dict<any>
```

### 方法

```
new(tabid, run_mode, cmd_template)
  # 手动初始化继承字段（Vim9 无法调用 super.New）
  # this.tabid, this.tag = nr2char(tabid + 65)

BuildCommand(): string
  # 替换 cmd_template 中的 % → expand('%:p')

ModeInit(): bool
  # 保存快捷键、设置 filepath、Mode（mark）初始化

ModeExit()
  # 恢复快捷键、清理 job/term/buffer、Mode（mark）退出

Copen(title: string)
  # 打开 quickfix 窗口

Cnext() / Cprev()
  # quickfix 错误导航（catch E553）

Execute(): bool
  # 按 run_mode 分发：'term' → RunTerm，'job' → RunJob

RunJob(cmd: string)
  # job_start + callback → caddexpr 到 quickfix
  # 处理 debug_buffer_limit / grep_buffer_limit

RunTerm(cmd: string)
  # term_start + 错误文件 $HOME/.cache/vim/error → quickfix
  # 处理 exit_cb

StartTimer(interval, cb)
  # Mypy 文件监听：检查 mtime，变更则重新执行
```

### 子类可覆盖的钩子

- `DecideSrc(): bool` — 文件类型判断（默认按 FileType 判断）
- `Execute()` — Mypy 的 timer 触发逻辑
- `BuildCommand()` — Grep 动态拼接搜索参数

## 各 mode 配置

| Mode | run_mode | cmd_template | 触发 |
|------|----------|--------------|------|
| RunMode | term | `io -m -eq %` | 手动 `:Run` |
| DebugMode | job | `&makeprg`（% 替换） | 手动 `:Run -d` |
| GrepMode | job | `rg --no-heading -n <content> <path>`（动态） | `:Grep` / operator |
| MypyMode | job | `dmypy check %` | timer 监听文件变更 |

## :Run 命令接口

```
:Run                        → 打开 cmdline 预填 "Run io -m -eq %"
:Run python3 %              → term 模式，cmd = "python3 <filepath>"
:Run -d gcc -Wall -o % %    → job 模式，cmd = "gcc ..."，输出→quickfix
```

`%` 占位符自动替换为当前文件的绝对路径（`expand('%:p')`）。

### 命令解析（类似 ParseGrepArgs）

```
:Run <args...>
  - 无参数 → 打开 cmdline 窗口，预填 "Run io -m -eq %"
  - 第一个参数为 -d → DebugMode（job 模式）
  - 其余参数 join 为命令字符串，替换 % 后执行
```

无参数时打开 cmdline 的机制参考现有 `GrepModeEdit`：
```vim
autocmd CmdwinEnter * ++once setline('.', "Run io -m -eq %") | cursor(0, line('.'))
```

## ModeManager / TabPage 重构

```vim
class TabPage
    var tabid: number
    var curr_mode: string = ''
    var run_mode:  RunMode
    var debug_mode: DebugMode      # 新增（原为 RunMode.Debug 方法）
    var grep_mode: GrepMode        # 新增（原来 GrepMode 是静态类）
    var mypy_mode: MypyMode
endclass
```

- `GrepMode` 从**静态类**改为**实例类**，`TabPage` 持有实例。
- 所有 `GrepMode.xxx()` 静态调用改为通过实例（如 `this.grep_mode.xxx()`），包括：
  - vimrc 中的 `<leader>g` operator 绑定
  - MypyMode 中的 `GrepMode.Cnext()`/`GrepMode.Cprev()`
  - `ParseGrepArgs` 中的 `GrepMode.Grep()`
- `ModeManager` 的 `ExitMode` 分发逻辑保持（`if/elseif curr_mode` → 调用对应实例的 `ModeExit`）。

### 命令定义调整

```vim
command -nargs=* Run  ParseRunArgs(<f-args>)     # 替代 -nargs=0 RunMode
command -nargs=+ Grep ParseGrepArgs(<f-args>)    # 保留
command -nargs=0 MypyMode  ...                    # 保留
```

移除：
- `command -nargs=0 RunMode` → 由 `:Run`（-nargs=*）取代
- `command -nargs=0 RunModeStrict`（`-s` 标志，改为自定义命令控制）
- `command -nargs=0 RunModeWithArgs`（`input()` 交互，改为 cmdline 预填）

`DebugMode`：不再作为独立命令，由 `:Run -d` 触发（内部使用 DebugMode 类）。`<leader>d` 映射改为 `:Run -d` 或直接移除（交由用户配置）。

### vimrc 映射调整

```vim
" 原映射                          新映射
au VimEnter * nn <leader>r  →   :Run<CR>                （cmdline 预填，回车执行）
au VimEnter * nn <leader>ir →   移除（功能并入 :Run 无参预填）
au VimEnter * nn <leader>sr →   移除（-s 已弃用，由自定义命令控制）
au VimEnter * nn <leader>d  →   :Run -d<CR>             （job 模式）
au VimEnter * nn <leader>g  →   GrepMode operator（改为实例调用）
```

## 保留的现有功能清单

- [x] `ModeManager` tab 注册/查询（`GetTabID`/`Register`/`CheckOut`）
- [x] `ModeManager.ExitMode` 分发
- [x] MypyMode 文件变更监听（timer + mtime）
- [x] GrepMode operator 模式（`g@`，选中文本搜索）
- [x] GrepMode buffer 清理（`loaded_buf_nr`）
- [x] GrepMode `grep_buffer_limit`
- [x] RunMode 错误文件 `$HOME/.cache/vim/error` 处理
- [x] RunMode `TimeStamp` 防重复运行机制
- [x] RunMode `_DecideSrc` 文件类型判断
- [x] quickfix 导航快捷键 `<c-n>`/`<c-p>`

## 错误处理

- `job_start` 失败（`job_status` 非 'run'）→ `echom` 提示
- 命令退出码非 0（term 模式）→ 读取错误文件 → 填充 quickfix → 打开 qf 窗口
- quickfix 导航越界 → `catch /E553/` → `echom '没有更多错误'`

## 测试策略

由于是 vim9script 插件代码，测试方式：

1. **语法检查**：`vim -es -V1 -c "source ~/.vim/functions/mode.vim" -c "qa!"` 无报错
2. **继承测试**：写临时 vim9 测试文件验证 extends/覆盖/字段初始化
3. **手动功能测试**：
   - `:Run`（无参）→ cmdline 预填
   - `:Run python3 %` → term 模式运行 python 文件
   - `:Run -d gcc %` → job 模式，错误进 quickfix
   - `:Grep` 原有功能不回归
   - `:Mypy` 文件保存自动检查
   - tab 切换后各 mode 状态独立

## 风险与注意

1. **Vim9 继承限制**：基类构造函数不能调用，子类需手动初始化继承字段 → 已在测试中验证可行
2. **方法覆盖无 `override` 关键字**：此 Vim 版本（9.1）同名同签名即可覆盖，无需关键字
3. **GrepMode 静态改实例**：涉及多处调用点修改，需逐一排查（vimrc、MypyMode、ParseGrepArgs）
4. **`defcompile`**：文件末尾有 `# defcompile`，修改后需确保编译通过

## 文件改动范围

- `vim/functions/mode.vim` — 主要改动（新增 CommandRunner、改造 4 个 mode、TabPage、命令定义）
- `vimrc` — 修改 GrepMode 静态调用为实例调用（`<leader>g` 相关）
