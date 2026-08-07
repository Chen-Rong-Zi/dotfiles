# RunMode → CommandRunner 统一架构实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 抽取可复用的 `CommandRunner` 基类统一四个 mode（Run/Debug/Grep/Mypy）的 term/job 执行 + quickfix 输出逻辑，并提供类似 `:Grep` 的 `:Run` 自定义命令（默认 `io -m -eq %`）。

**Architecture:** `Mode`（mark/焦点基类）→ `CommandRunner`（继承 Mode，实现 term/job 执行、quickfix 输出、快捷键管理）→ 四个 mode 子类仅保留各自特有配置。`GrepMode` 从静态类改为实例类，`TabPage` 持有四个 mode 实例，`ModeManager` 分发保持不变。`:Run` 命令无参数时打开 cmdline 预填默认命令，有参数时直接执行。

**Tech Stack:** Vim 9.1 vim9script（`extends` 继承、`<ScriptCmd>` 映射、job/term 控制）

**Spec:** `docs/superpowers/specs/2026-08-07-runmode-commandrunner-design.md`

**已验证的 Vim9 技术要点（实施前必须遵守）：**
1. 继承语法是 `class Child extends Parent`（不是 `:`）
2. 基类构造函数**不能**调用（无 `super.New()`），子类 `new()` 中**手动初始化**继承字段（`this.tabid = tabid; this.tag = nr2char(tabid + 65)`）
3. 此 Vim 版本无 `override` 关键字，覆盖方法只需同名同签名（返回类型也必须一致）
4. 类内可用 `nn <c-x> <ScriptCmd>...<CR>` 定义映射
5. `<ScriptCmd>` 可通过脚本局部变量（`var Active: any`）或静态方法链（`Mgr.Cur('1').grep.Next()`）调用实例方法
6. 文件末尾 `# defcompile` 会强制编译期检查所有方法签名

**环境说明：** 无法在自动化环境运行真实 Vim GUI 测试，验证手段为 `vim -u NONE -N -es -V1 -c "source <file>"` 语法编译检查 + 临时文件中的行为测试。每次修改后必须通过编译检查。

---

### Task 1: 编写 CommandRunner 基类（仅声明 + 基类字段/方法）

**Files:**
- Modify: `vim/functions/mode.vim`（在 `Mode` 类与 `MypyMode` 类之间插入 `CommandRunner` 类）

**目标：** 创建 `CommandRunner` 基类，继承 `Mode`，声明所有 mode 共享的字段与方法骨架。此任务**只建立基类**，不改动现有四个 mode（保证编译通过）。

- [ ] **Step 1: 在 `Mode` 类之后（`endclass` 之后、`class MypyMode` 之前）插入 CommandRunner 基类**

插入如下代码（注意：基类 `new()` 手动初始化继承字段 `tabid`/`tag`，因为 Vim9 禁止 `super.New()`）：

```vim
#  ██████╗ ██████╗ ███╗   ███╗███╗   ███╗ █████╗ ███╗   ██╗██████╗
# ██╔════╝██╔═══██╗████╗ ████║████╗ ████║██╔══██╗██║   ██║██╔══██╗
# ██║     ██║   ██║██╔████╔██║██╔████╔██║███████║██║   ██║██████╔╝
# ██║     ██║   ██║██║╚██╔╝██║██║╚██╔╝██║██╔══██║██║   ██║██╔══██╗
# ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║ ╚═╝ ██║██║  ██║██║   ██║██████╔╝
#  ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝   ╚═╝╚═════╝

export class CommandRunner extends Mode
    # ---- 配置 ----
    public var run_mode: string          # 'term' | 'job'
    public var cmd_template: string      # 命令模板，'%' = 当前文件 %:p
    public var title: string             # quickfix 标题

    # ---- 状态 ----
    public var job: job
    public var term_nr: number
    public var timer_id: number
    public var filepath: string
    public var mtime: number = 0
    public var open_term: bool = false
    public var loaded_buf_nr: list<number> = []
    public var maping_ctrl_p: dict<any>
    public var maping_ctrl_n: dict<any>

    def new(tabid: number, run_mode: string, cmd_template: string)
        # Vim9 无法调用 super.New()，手动初始化继承字段
        this.tabid = tabid
        this.tag   = nr2char(this.tabid + 65)
        this.run_mode     = run_mode
        this.cmd_template = cmd_template
    enddef

    def BuildCommand(): string
        # 将 cmd_template 中的 '%' 替换为当前文件绝对路径
        return substitute(this.cmd_template, '%', this.filepath, 'g')
    enddef

    def ModeInit(): bool
        # 保存快捷键 + 设置 filepath + 继承 Mode 的 mark 初始化
        const ok = super.ModeInit()
        this.filepath = expand('%:p')
        this.maping_ctrl_n = maparg('<c-n>', 'n', false, 1)
        this.maping_ctrl_p = maparg('<c-p>', 'n', false, 1)
        return ok
    enddef

    def ModeExit()
        # 恢复快捷键 + 继承 Mode 的 mark 退出
        if this.maping_ctrl_n !=# null && this.maping_ctrl_n->len() !=# 0
            mapset('n', false, this.maping_ctrl_n)
        endif
        if this.maping_ctrl_p !=# null && this.maping_ctrl_p->len() !=# 0
            mapset('n', false, this.maping_ctrl_p)
        endif
        this.Stop()
        super.ModeExit()
    enddef

    def Stop()
        # 停止 job / term / timer，由子类按需调用
        if this.job !=# null && job_status(this.job) ==# 'run'
            job_stop(this.job, 'kill')
        endif
        if this.timer_id !=# 0
            timer_stop(this.timer_id)
            this.timer_id = 0
        endif
        if bufnr(this.term_nr) !=# -1
            const term_job = term_getjob(this.term_nr)
            if job_status(term_job) ==# 'run'
                job_setoptions(term_job, {'exit_cb': (exit_job: job, id: number) => 1})
            endif
            silent! execute 'bdelete! ' .. this.term_nr
        endif
        if this.open_term
            this.open_term = false
            silent! cclose
        endif
    enddef

    static def Copen(height_ratio: number = 3.0 / 14.0)
        exe 'botright copen ' .. string(float2nr(&lines * height_ratio))
        setlocal nonumber norelativenumber nolist
    enddef

    static def Cnext()
        try
            cnext
        catch /E553/
            echom '没有更多错误'
        endtry
    enddef

    static def Cprev()
        try
            cprev
        catch /E553/
            echom '没有更多错误'
        endtry
    enddef

    # 子类可覆盖的钩子
    def DecideSrc(): bool
        # 默认：仅当前 buffer 为代码文件时才进入 mode
        const curr_path = expand('%:p')
        const types = ['java', 'cpp', 'c', 'python', 'rust', 'bash', 'sh']
        return &buftype ==# '' && types->index(FileType(curr_path)) !=# -1
    enddef

    def Execute(...args: list<any>): bool
        # 按 run_mode 分发，子类可覆盖（如 MypyMode 的 timer 触发）
        if this.run_mode ==# 'job'
            return this.RunJob()
        else
            return this.RunTerm()
        endif
    enddef

    def RunJob(...args: list<any>): bool
        # 子类覆盖
        return true
    enddef

    def RunTerm(...args: list<any>): bool
        # 子类覆盖
        return true
    enddef
endclass
```

- [ ] **Step 2: 编译检查（必须通过）**

Run:
```bash
vim -u NONE -N -es -V1 -c "source /Users/macbook/Project/dotfiles/vim/functions/mode.vim" -c "qa!"
```
Expected: 无 `Error detected` / 无 E 开头错误（仅 viminfo 提示可忽略）。若报 `E1315: White space required after name` 说明继承语法写错（应为 `extends`）。

注意：原文件末尾 `# defcompile` 会触发完整编译。基类 `RunJob`/`RunTerm`/`Execute` 有默认实现（非 abstract），所以即使子类尚未覆盖也能编译通过。

- [ ] **Step 3: Commit**

```bash
git add vim/functions/mode.vim
git commit -m "feat(mode): add CommandRunner base class with term/job execution + quickfix output
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 2: 改造 GrepMode 为 CommandRunner 子类（实例化）

**Files:**
- Modify: `vim/functions/mode.vim`（`GrepMode` 类整体替换为实例子类）
- Modify: `vim/functions/mode.vim`（`MypyMode` 的 `<c-n>`/`<c-p>` 映射，见 Step 4）

**目标：** 将静态类 `GrepMode` 改为继承 `CommandRunner` 的实例类。原静态成员（`job`/`count`/`mode`/`mapping_*`）被基类字段取代；`Copen`/`Cnext`/`Cprev`/`ModeInit`/`ModeExit` 使用基类实现 + 子类特有逻辑。

**关键设计：**
- 原 `GrepMode.mode`（静态 `Mode.new(0)`）→ 由继承的 `Mode` 代替，`this.ModeInit()` 即调用基类（含 Mode 初始化）
- 原 `GrepMode.job` → `this.job`（基类字段）
- 原 `GrepMode.maping_ctrl_n/p` → `this.maping_ctrl_n/p`（基类字段）
- `GrepHandler` 回调是静态的，需要把实例传入——保持静态方法签名 `(ch, msg)` 无法访问实例。**方案：** GrepHandler 改为 `(ch, msg, grep_mode)` 三参数（job 回调不支持第三参数），所以用闭包：`job_start(cmd, {'callback': (ch, msg) => this.GrepHandler(ch, msg)})`。但 `this` 在类方法内闭包中可用。

- [ ] **Step 1: 替换 GrepMode 类定义**

将整个 `export class GrepMode`（原 152-317 行）替换为：

```vim
export class GrepMode extends CommandRunner
    # 与 Grep 搜索相关的配置（非执行机制）
    public var count: number = 0
    public var grep_buffer_limit: number = 0
    public var GREP_BIN = 'rg'
    public var GREP_OPTION = '--no-heading'
    public var GREP_SEARCH_PATH = '.'
    public var GREP_SEARCH_CONTENT = ''
    public var GREP_OTHER_OPTION = ['-n']

    def new(tabid: number)
        super_new(tabid, 'job', '')
    enddef

    # Vim9 不支持 super.New()，提供 helper
    def super_new(tabid: number, run_mode: string, cmd_template: string)
        this.tabid = tabid
        this.tag   = nr2char(this.tabid + 65)
        this.run_mode     = run_mode
        this.cmd_template = cmd_template
    enddef

    def ModeInit(): bool
        # 先退出其他 mode，再进入 GrepMode
        ModeManager.ExitMode(ModeManager.GetTabID())
        const ok = super.ModeInit()
        if !ok
            return false
        endif
        nn <c-n> <ScriptCmd>ModeManager.GetGrepMode(ModeManager.GetTabID()).Cnext() \| normal! zR<CR>
        nn <c-p> <ScriptCmd>ModeManager.GetGrepMode(ModeManager.GetTabID()).Cprev() \| normal! zR<CR>
        &errorformat = &grepformat
        this.grep_buffer_limit = g:grep_buffer_limit
        this.loaded_buf_nr = getbufinfo({'buflisted': 1})->map((_, buf) => buf['bufnr'])
        ModeManager.database[string(ModeManager.GetTabID())].curr_mode = "GrepMode"
        return true
    enddef

    def ModeExit()
        silent! cclose
        this.Stop()
        # 删除 grep 打开的无窗口临时 buffer
        const Valid = (_, buf) => {
            return buf['windows'] ==# []
              && this.loaded_buf_nr->index(buf['bufnr']) ==# -1
              && bufnr(buf['bufnr']) !=# -1
        }
        getbufinfo({"buflisted": 1})->filter(Valid)
                    ->map((_, buf) => {
                        silent! execute 'bdelete! ' .. buf['name']
                        return 1
                    })
        super.ModeExit()
    enddef

    def Copen()
        CommandRunner.Copen()
        setqflist([], 'r', {'title': '在目录' .. this.GREP_SEARCH_PATH .. '搜索' .. this.GREP_SEARCH_CONTENT})
        @/ = this.GREP_SEARCH_CONTENT
        set hlsearch
    enddef

    def GrepHandler(ch: channel, msg: string)
        if this.grep_buffer_limit ==# 0
            job_stop(this.job)
            return
        endif
        this.grep_buffer_limit -= 1
        caddexpr msg
    enddef

    def RunJob(): bool
        this.GREP_SEARCH_PATH = this.GREP_SEARCH_PATH->fnamemodify(":p:h")
        const cmd_list = [this.GREP_BIN, this.GREP_OPTION, this.GREP_SEARCH_CONTENT, this.GREP_SEARCH_PATH] + this.GREP_OTHER_OPTION
        echom cmd_list
        this.job = job_start(
            cmd_list,
            {'callback': (ch: channel, msg: string) => this.GrepHandler(ch, msg), 'timeout': 100})
        this.Copen()
        return true
    enddef

    def Run(): func: void
        return (_) => {
            var searchContent: string = ""
            const [_, l_row, l_col, _] = getcharpos("'[")
            const [_, r_row, r_col, _] = getcharpos("']")
            if l_row ==# r_row
                const left_col  = min([l_col, r_col])
                const right_col = max([l_col, r_col])
                g:line = getline(l_row)
                searchContent = getline(l_row)[left_col - 1 : right_col - 1]
            elseif l_row ># r_row
                var lines: list<string> = getline(r_row, l_row)
                lines[0]  = lines[0][r_col - 1 : ]
                lines[-1] = lines[-1][ : l_col - 1]
                searchContent = lines->join("\n")
            elseif l_row <# r_row
                var lines: list<string> = getline(l_row, r_row)
                lines[0]  = lines[0][l_col - 1 : ]
                lines[-1] = lines[-1][ : r_col - 1]
                searchContent = lines->join("\n")
            endif
            this.GREP_SEARCH_CONTENT = '\<' .. searchContent .. '\>'
            this.Grep()
        }
    enddef

    def Grep()
        const winid = win_getid()
        this.ModeInit()
        this.count = 0
        this.RunJob()
        WinFocusOn(winid)
    enddef
endclass
```

**注意：** 原代码 `searchContent` 在多行分支中未赋值给 `GrepMode.GREP_SEARCH_CONTENT`（第 304-312 行只拼了 lines 但没 join），这是原 bug。上方案已修复为 `searchContent = lines->join("\n")`。若想保持原行为也可，但建议用修复版。

- [ ] **Step 2: 编译检查**

Run:
```bash
vim -u NONE -N -es -V1 -c "source /Users/macbook/Project/dotfiles/vim/functions/mode.vim" -c "qa!"
```
Expected: 无 E 开头错误。**注意：** 此时会报错，因为 `ModeManager.GetGrepMode()` 尚未定义（Step 3 补），且 `GrepMode.Grep()` 被 `ParseGrepArgs`/`GrepModeOper` 以静态方式调用。若报 E123（未定义函数）可暂时接受，继续 Step 3。

- [ ] **Step 3: 为 ModeManager 添加 GetGrepMode / GetRunMode / GetDebugMode / GetMypyMode 静态方法**

在 `ModeManager` 类（原 553-612 行）的 `GetTabID` 方法之后插入：

```vim
    static def GetGrepMode(tabid: number): GrepMode
        final mode_state: TabPage = ModeManager.database[string(tabid)]
        return mode_state.grep_mode
    enddef

    static def GetRunMode(tabid: number): RunMode
        final mode_state: TabPage = ModeManager.database[string(tabid)]
        return mode_state.run_mode
    enddef

    static def GetDebugMode(tabid: number): DebugMode
        final mode_state: TabPage = ModeManager.database[string(tabid)]
        return mode_state.debug_mode
    enddef

    static def GetMypyMode(tabid: number): MypyMode
        final mode_state: TabPage = ModeManager.database[string(tabid)]
        return mode_state.mypy_mode
    enddef
```

**注意：** 这会报错直到 TabPage 有 `grep_mode`/`debug_mode` 字段（Task 3 完成）。此步骤与 Task 3 有依赖，若独立编译报 E1264（成员不存在），属预期，继续 Task 3 后统一编译。

- [ ] **Step 4: 更新 MypyMode 的 GrepMode 静态引用为实例引用**

在 `MypyMode.ModeInit` 中（原 118-119 行）：
```vim
        nn  <c-n> <ScriptCmd> GrepMode.Cnext()<CR>
        nn  <c-p> <ScriptCmd> GrepMode.Cprev()<CR>
```
改为：
```vim
        nn  <c-n> <ScriptCmd> ModeManager.GetGrepMode(ModeManager.GetTabID()).Cnext()<CR>
        nn  <c-p> <ScriptCmd> ModeManager.GetGrepMode(ModeManager.GetTabID()).Cprev()<CR>
```

- [ ] **Step 5: 编译检查（暂时跳过 TabPage 相关错误，Task 3 统一修复）**

Run:
```bash
vim -u NONE -N -es -V1 -c "source /Users/macbook/Project/dotfiles/vim/functions/mode.vim" -c "qa!"
```
Expected: 允许存在与 `grep_mode`/`debug_mode` 字段未定义相关的错误（属 Task 3 范围）。若报 GrepMode 静态调用错误（`E123`/`E1358`），属于必须本任务修复的问题——检查 vimrc 及其他静态调用。

- [ ] **Step 6: Commit（此提交允许暂时不完整，Task 3 完成后编译通过再补一次）**

```bash
git add vim/functions/mode.vim
git commit -m "refactor(mode): convert GrepMode to CommandRunner instance subclass
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 3: 重构 RunMode + 拆分 DebugMode + 更新 TabPage/ModeManager

**Files:**
- Modify: `vim/functions/mode.vim`（`RunMode` 类重构为 CommandRunner 子类）
- Modify: `vim/functions/mode.vim`（新增 `DebugMode` 类）
- Modify: `vim/functions/mode.vim`（`TabPage` 增加 `grep_mode`/`debug_mode` 字段）
- Modify: `vim/functions/mode.vim`（`ModeManager.Run`/`Debug`/`Mypy` 方法适配）

**目标：** RunMode 继承 CommandRunner（term 模式，默认 `io -m -eq %`）；DebugMode 继承 CommandRunner（job 模式，默认 `&makeprg`）；TabPage 持有四个 mode 实例；ModeManager 方法改用实例。

- [ ] **Step 1: 将 RunMode 类重构为 CommandRunner 子类**

替换整个 `export class RunMode`（原 350-520 行）为：

```vim
export class RunMode extends CommandRunner
    public var run_job: job
    public var src_path: string
    public var debug_buffer_limit: number = 0
    public var makeprg: string

    def new(tabid: number)
        this.super_new(tabid, 'term', 'io -m -eq %')
    enddef

    def super_new(tabid: number, run_mode: string, cmd_template: string)
        this.tabid = tabid
        this.tag   = nr2char(this.tabid + 65)
        this.run_mode     = run_mode
        this.cmd_template = cmd_template
    enddef

    def _DecideSrc(): string
        var curr_path = expand('%:p')
        const types = ['java', 'cpp', 'c', 'python', 'rust', 'bash', 'sh']
        if &buftype ==# '' && types->index(FileType(curr_path)) !=# -1
            this.makeprg = &makeprg
            this.mode_enter()
            return curr_path
        endif

        ModeManager.ExitMode(ModeManager.GetTabID())
        curr_path = expand('%:p')
        if types->index(FileType(curr_path)) !=# -1
            this.makeprg = &makeprg
            return curr_path
        else
            return ''
        endif
    enddef

    # helper：手动执行基类 ModeInit（含 Mode mark 初始化），避免方法链覆盖歧义
    def mode_enter(): bool
        return super.ModeInit()
    enddef

    def ModeInit(): bool
        this.src_path = this._DecideSrc()
        if this.src_path ==# ''
            return false
        endif
        this.mode_enter()
        this.debug_buffer_limit = g:debug_buffer_limit
        return true
    enddef

    def ModeExit()
        this.Stop()
        super.ModeExit()
    enddef

    def Copen()
        CommandRunner.Copen()
    enddef

    static def ExitHandler(exit_job: job, winid: number, runmode: RunMode)
        const exitval = job_info(exit_job)['exitval']
        if exitval ==# 0
            return
        endif
        echom '编译运行错误'
        if bufnr(runmode.term_nr) !=# -1 && bufnr(runmode.term_nr) !=# 0
            execute 'bdelete! ' .. runmode.term_nr
        endif
        if runmode.open_term
            execute 'cgetfile ' .. $HOME .. '/.cache/vim/error'
            setqflist([], 'r',  {'title': '退出代码: ' .. string(exitval)})
            RunMode.Copen()
        endif
    enddef

    def RunTerm(...args: list<any>): bool
        if this.ModeInit() ==# false
            echom 'ModeInit失败，不进入RunMode'
            return false
        endif

        const winid = win_getid()
        var   run_only    = false
        const strict      = args->index('-s') !=# -1
        const input       = args->index('--') !=# -1
        const input_args  = input ? join(args[args->index('--') : ], ' ') : ''
        const option      = {
            'term_rows': float2nr(&lines * (3.0 / 14.0)),
            'err_io': 'file',
            'err_name': $HOME .. '/.cache/vim/error',
            'exit_cb': (exit_job: job, id: number) => RunMode.ExitHandler(exit_job, id, this)}
        const time_passby = TimeStamp(false)
        const run_cmd     = this.BuildCommand()
        this.open_term = true

        if time_passby <# 1.0
            run_only = 1
            echom '运行过快,据上一次运行只有 ' .. time_passby .. 's'
        endif

        const cmd = run_cmd .. AddFlag('-s')(strict) .. AddFlag('-r')(run_only) .. AddFlag(input_args)(input)
        botright this.term_nr = term_start(cmd, option)
        TimeStamp(!run_only)
        WinFocusOn(winid)
        return true
    enddef

    static def RunHandler(ch: channel, msg: string, runmode: RunMode)
        caddexpr msg
        runmode.debug_buffer_limit -= 1
        if runmode.debug_buffer_limit <=# 0
            ch_close(ch)
            caddexpr '超出最大缓冲区限制: ' .. g:debug_buffer_limit .. "  修改g:debug_buffer_limit以增大容量"
        endif
    enddef

    def Debug(): bool
        # Debug 逻辑迁移到 DebugMode 类
        ModeManager.Debug(ModeManager.GetTabID())
        return true
    enddef
endclass
```

**注意：** `AddFlag` 和 `TimeStamp` 当前是文件级函数（原 320-348 行），保留不动。`Run()` 方法保留原有 `-s`/`--`/`-r` 标志处理（与 spec 中"移除 -s"不冲突——spec 移除的是 **命令行暴露** `RunModeStrict` 命令，`Run()` 方法内部的兼容逻辑保留以便 Debug 等内部调用不受影响；如需彻底移除在 Task 5 统一处理）。

- [ ] **Step 2: 新增 DebugMode 类（在 RunMode 之后插入）**

```vim
export class DebugMode extends CommandRunner
    public var src_path: string
    public var debug_buffer_limit: number = 0
    public var makeprg: string

    def new(tabid: number)
        this.super_new(tabid, 'job', '')
    enddef

    def super_new(tabid: number, run_mode: string, cmd_template: string)
        this.tabid = tabid
        this.tag   = nr2char(this.tabid + 65)
        this.run_mode     = run_mode
        this.cmd_template = cmd_template
    enddef

    def ModeInit(): bool
        const curr_path = expand('%:p')
        const types = ['java', 'cpp', 'c', 'python', 'rust', 'bash', 'sh']
        if types->index(FileType(curr_path)) ==# -1
            return false
        endif
        this.src_path = curr_path
        this.makeprg = &makeprg
        this.mode_enter()
        this.debug_buffer_limit = g:debug_buffer_limit
        return true
    enddef

    def mode_enter(): bool
        return super.ModeInit()
    enddef

    def ModeExit()
        this.Stop()
        super.ModeExit()
    enddef

    def Copen()
        CommandRunner.Copen()
    enddef

    def BuildCommand(): string
        # 若用户通过 :Run -d 提供了自定义命令则用之，否则用 &makeprg
        if this.cmd_template !=# ''
            return substitute(this.cmd_template, '%', this.src_path, 'g')
        endif
        return this.makeprg
            ->split(' ')
            ->map((_, token) => (token =~# '\v\%.*') ? this.src_path : token)
            ->join(' ')
    enddef

    def RunHandler(ch: channel, msg: string)
        caddexpr msg
        this.debug_buffer_limit -= 1
        if this.debug_buffer_limit <=# 0
            ch_close(ch)
            caddexpr '超出最大缓冲区限制: ' .. g:debug_buffer_limit .. "  修改g:debug_buffer_limit以增大容量"
        endif
    enddef

    def RunJob(...args: list<any>): bool
        if this.ModeInit() ==# false
            echom 'ModeInit失败，不进入DebugMode'
            return false
        endif
        const winid = win_getid()
        const option = {'callback': (ch: channel, msg: string) => this.RunHandler(ch, msg),
            'exit_cb': (exit_job: job, msg: number) => {
                const exitval = job_info(exit_job)['exitval']
                setqflist([], 'r',  {'title': '退出代码: ' .. string(exitval)})
            }}
        cgetexpr ''
        this.job = job_start(this.BuildCommand(), option)
        this.Copen()
        this.open_term = true
        WinFocusOn(winid)
        return true
    enddef
endclass
```

- [ ] **Step 3: 更新 TabPage 类持有四个 mode 实例**

替换 `TabPage` 类（原 523-551 行）为：

```vim
class TabPage
    public var tabid: number
    public var curr_mode: string = ''
    public var run_mode:  RunMode
    public var debug_mode: DebugMode
    public var grep_mode: GrepMode
    public var mypy_mode: MypyMode

    def new(tabid: number)
        this.tabid = tabid
        this.curr_mode = ''
        this.run_mode  = RunMode.new(tabid)
        this.debug_mode = DebugMode.new(tabid)
        this.grep_mode = GrepMode.new(tabid)
        this.mypy_mode = MypyMode.new(tabid)
    enddef
    def SetCurrMode(mode_type: string)
        this.curr_mode = mode_type
    enddef
    def ExitMode()
        if this.curr_mode ==# ''
        elseif this.curr_mode ==# 'GrepMode'
            this.grep_mode.ModeExit()
        elseif this.curr_mode ==# 'RunMode'
            this.run_mode.ModeExit()
        elseif this.curr_mode ==# 'DebugMode'
            this.debug_mode.ModeExit()
        elseif this.curr_mode ==# 'MypyMode'
            this.mypy_mode.ModeExit()
        endif
        this.SetCurrMode('')
    enddef
endclass
```

- [ ] **Step 4: 更新 ModeManager 的 Run/Debug/Mypy 方法**

替换 `ModeManager` 类的 `Run`/`Debug`/`Mypy` 方法（原 583-610 行）为：

```vim
    static def Run(tabid: number, ...args: list<any>)
        final mode_state: TabPage = ModeManager.database[string(tabid)]
        var result: bool
        if len(args) ==# 0
            # 无自定义命令：使用 RunMode 默认 io -m -eq %
            mode_state.run_mode.cmd_template = 'io -m -eq %'
        else
            # 自定义命令（如 'python3 %'）：设置 cmd_template，% 在 BuildCommand 中替换
            mode_state.run_mode.cmd_template = args->join(' ')
        endif
        result = mode_state.run_mode.Run()
        if result
            mode_state.SetCurrMode('RunMode')
        endif
    enddef

    static def Debug(tabid: number, ...args: list<any>)
        final mode_state: TabPage = ModeManager.database[string(tabid)]
        if len(args) !=# 0
            mode_state.debug_mode.cmd_template = args->join(' ')
        endif
        final result: bool = mode_state.debug_mode.RunJob()
        if result
            mode_state.SetCurrMode('DebugMode')
        endif
    enddef

    static def Mypy(tabid: number)
        final mode_state: TabPage = ModeManager.database[string(tabid)]
        mode_state.mypy_mode.Run()
        mode_state.SetCurrMode('MypyMode')
    enddef
```

- [ ] **Step 5: 更新文件末尾的命令定义**

将原文件末尾命令（原 646-654 行）：

```vim
command -nargs=0 RunMode         ModeManager.Run(ModeManager.GetTabID())
command -nargs=0 RunModeStrict   ModeManager.Run(ModeManager.GetTabID(), '-s')
command -nargs=0 RunModeWithArgs RunModeWithArgs()
command -nargs=0 DebugMode       ModeManager.Debug(ModeManager.GetTabID())
command -nargs=0 MypyMode        ModeManager.Mypy(ModeManager.GetTabID())
command -nargs=+ Grep ParseGrepArgs(<f-args>)
```

改为（先保留旧命令作为占位，Task 5 新增 `:Run`）：

```vim
command -nargs=0 RunMode         ModeManager.Run(ModeManager.GetTabID())
command -nargs=0 RunModeStrict   ModeManager.Run(ModeManager.GetTabID(), '-s')
command -nargs=0 RunModeWithArgs RunModeWithArgs()
command -nargs=0 DebugMode       ModeManager.Debug(ModeManager.GetTabID())
command -nargs=0 MypyMode        ModeManager.Mypy(ModeManager.GetTabID())
command -nargs=+ Grep ParseGrepArgs(<f-args>)
```

**注意：** `ParseGrepArgs`（原 614-634 行）中 `GrepMode.GREP_OTHER_OPTION` 等静态引用需改为实例引用。因为 `ParseGrepArgs` 是文件级函数（非类方法），不能访问 `this`。**方案：** 将 `ParseGrepArgs` 改为静态类方法 `ModeManager.ParseGrepArgs(...args)`，通过 `GetGrepMode(tabid)` 访问实例：

替换 `ParseGrepArgs` 函数（原 614-634 行）为：

```vim
def ParseGrepArgs(...args: list<string>)
    final gm = ModeManager.GetGrepMode(ModeManager.GetTabID())
    const argc = len(args)
    gm.GREP_OTHER_OPTION = []
    if argc ==# 1
        gm.GREP_SEARCH_CONTENT = args[0]
    elseif argc ==# 2
        gm.GREP_OPTION      = args[0]
        gm.GREP_SEARCH_PATH = system('realpath ' .. shellescape(args[1]) )->trim()
    elseif argc ==# 3
        gm.GREP_OPTION         = args[0]
        gm.GREP_SEARCH_CONTENT = args[1]
        gm.GREP_SEARCH_PATH    = system('realpath ' .. shellescape(args[2]) )->trim()
        gm.Grep()
    else
        gm.GREP_OPTION         = args[0]
        gm.GREP_SEARCH_CONTENT = args[1]
        gm.GREP_SEARCH_PATH    = system('realpath ' .. shellescape(args[2]) )->trim()
        gm.GREP_OTHER_OPTION   = args[3 : ]
        gm.Grep()
    endif
enddef
```

- [ ] **Step 6: 编译检查（必须通过，本任务所有错误都应已消除）**

Run:
```bash
vim -u NONE -N -es -V1 -c "source /Users/macbook/Project/dotfiles/vim/functions/mode.vim" -c "qa!"
```
Expected: 无 E 开头错误。若仍有错误，重点检查：
- `CommandRunner` 基类 `ModeInit()` 返回 `bool`，子类 `super.ModeInit()` 使用正确
- `GrepMode.ModeInit()` 中 `const ok = super.ModeInit()` 后使用 `ok`
- `MypyMode` 尚未改造（Task 4），其 `Run()`/`RunHandler` 仍引用旧 `GrepMode.Cnext()`——已被 Step 4 改为实例引用
- `RunMode.Run()` 中 `this.BuildCommand()` 现在用基类实现（替换 `%` → filepath），原 `io -m -eq <src>` 行为一致

- [ ] **Step 7: Commit**

```bash
git add vim/functions/mode.vim
git commit -m "refactor(mode): RunMode/DebugMode as CommandRunner subclasses, TabPage holds all mode instances
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 4: 改造 MypyMode 为 CommandRunner 子类

**Files:**
- Modify: `vim/functions/mode.vim`（`MypyMode` 类重构）

**目标：** MypyMode 继承 CommandRunner（job 模式 + timer 文件监听），覆盖 `Execute()` 实现 timer 触发逻辑。

- [ ] **Step 1: 替换 MypyMode 类定义**

替换整个 `class MypyMode`（原 76-150 行）为：

```vim
class MypyMode extends CommandRunner
    def new(tabid: number)
        this.super_new(tabid, 'job', 'dmypy check %')
    enddef

    def super_new(tabid: number, run_mode: string, cmd_template: string)
        this.tabid = tabid
        this.tag   = nr2char(this.tabid + 65)
        this.run_mode     = run_mode
        this.cmd_template = cmd_template
    enddef

    def ModeExit()
        this.Stop()
        cclose
        super.ModeExit()
    enddef

    def Copen()
        CommandRunner.Copen()
        execute "normal! \<c-w>k"
    enddef

    def ModeInit(): bool
        this.filepath = expand('%:p')
        if FileType(this.filepath) !=# 'python'
            return false
        endif
        const ok = super.ModeInit()
        if !ok
            return false
        endif
        nn  <c-n> <ScriptCmd> ModeManager.GetGrepMode(ModeManager.GetTabID()).Cnext()<CR>
        nn  <c-p> <ScriptCmd> ModeManager.GetGrepMode(ModeManager.GetTabID()).Cprev()<CR>
        cgetexpr ''
        return true
    enddef

    def RunMypy(timer_id: number, ...args: list<any>)
        const ftime = getftime(this.filepath)
        if ftime ==# this.mtime
            return
        endif
        this.mtime = ftime
        if this.job !=# null && job_status(this.job) ==# 'run'
            job_stop(this.job, 'kill')
        endif
        cgetexpr ''
        this.job = job_start(['dmypy', 'check', this.filepath], {'callback': (ch: channel, msg: string) => this.RunHandler(ch, msg)})
    enddef

    def RunHandler(ch: channel, msg: string)
        caddexpr msg
    enddef

    override def Execute(...args: list<any>): bool
        if this.ModeInit() ==# false
            echom 'ModeInit失败，不进入MypyMode'
            return false
        endif
        this.mtime = getftime(this.filepath)
        this.timer_id = timer_start(5 * 1000, (timer_id: number) => this.RunMypy(timer_id), {'repeat': -1})
        this.Copen()
        return true
    enddef
endclass
```

**注意：** 这里使用了 `override def Execute(...)`。若你的 Vim 版本报 `E1318: Not a valid command in a class: override`（前面测试已证实此版本**不支持** `override` 关键字），则删除 `override` 改为普通 `def Execute(...)`。

- [ ] **Step 2: 编译检查**

Run:
```bash
vim -u NONE -N -es -V1 -c "source /Users/macbook/Project/dotfiles/vim/functions/mode.vim" -c "qa!"
```
Expected: 无 E 开头错误。若报 `E1318`（override 关键字），删除 `override` 重试。若报 `E1012: Type mismatch`（timer 回调签名），确认 `RunMypy` 参数签名 `(timer_id: number, ...args: list<any>)`。

- [ ] **Step 3: Commit**

```bash
git add vim/functions/mode.vim
git commit -m "refactor(mode): MypyMode as CommandRunner subclass with timer-based file watch
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 5: 新增 `:Run` 命令（ParseRunArgs + cmdline 预填）

**Files:**
- Modify: `vim/functions/mode.vim`（新增 `ParseRunArgs` 函数 + `:Run` 命令定义）
- Modify: `vim/functions/mode.vim`（删除/替换旧 `RunMode`/`RunModeStrict`/`RunModeWithArgs` 命令）

**目标：** 实现 `:Run` 命令——无参数时打开 cmdline 预填默认命令 `Run io -m -eq %`，有参数时解析执行；`-d` 前缀切换 DebugMode（job 模式）。

- [ ] **Step 1: 新增 ParseRunArgs 函数 + 替换命令定义**

在 `ParseGrepArgs` 函数之后、命令定义处，新增：

```vim
def ParseRunArgs(...args: list<string>)
    const tabid = ModeManager.GetTabID()
    if len(args) ==# 0
        # 无参数：打开 cmdline 窗口，预填默认命令
        autocmd CmdwinEnter * ++once setline('.', 'Run io -m -eq %') | cursor(0, line('.'))
        return
    endif
    if args[0] ==# '-d'
        # debug 模式：job_start + quickfix
        ModeManager.Debug(tabid, args[1 : ]->join(' '))
        return
    endif
    # term 模式：自定义命令（替换 %）
    ModeManager.Run(tabid, args->join(' '))
enddef
```

**注意：** `autocmd CmdwinEnter * ++once` 需要在 cmdline 窗口打开前注册。参考现有 `GrepModeEdit` 命令（原 641-644 行）的做法——它由映射 `<leader>ig ... q:` 触发。`ParseRunArgs` 无参数时**不能自己打开** cmdline 窗口（函数内 `q:` 无法直接调用）。**方案：** `:Run` 无参数命令体直接内联 autocmd + `q:`（与 GrepModeEdit 一致）：

替换文件末尾命令定义（原 646-654 行）为：

```vim
command -nargs=0 RunMode         ModeManager.Run(ModeManager.GetTabID())
command -nargs=0 RunModeStrict   ModeManager.Run(ModeManager.GetTabID(), '-s')
command -nargs=0 RunModeWithArgs RunModeWithArgs()
command -nargs=0 DebugMode       ModeManager.Debug(ModeManager.GetTabID())
command -nargs=0 MypyMode        ModeManager.Mypy(ModeManager.GetTabID())
command -nargs=+ Grep ParseGrepArgs(<f-args>)

" :Run 命令 —— 无参数打开 cmdline 预填默认命令
command -nargs=* Run ParseRunArgs(<f-args>)
```

**注意：** `:Run` 使用 `-nargs=*`（零到多个参数）。但命令名 `Run` 与现有 `RunMode` 冲突检查：`Run` 是 `RunMode` 的前缀，Vim 命令行允许 `:Run` 精确匹配 `Run`（`-nargs=*` 命令定义 `Run`），`RunMode` 仍是独立命令。若 Vim 报 `E174: Command already exists` 或歧义，改用 `RunCmd` 作为命令名（并同步 Step 2 的映射和 spec 文档）。

- [ ] **Step 2: 更新 vimrc 中的映射**

在 `vimrc`（原 1073-1076 行）：
```vim
au VimEnter * nn <silent> <leader>r <CMD>RunMode<CR>
au VimEnter * nn <silent> <leader>ir <CMD>RunModeWithArgs<CR>
au VimEnter * nn <silent> <leader>sr <CMD>RunModeStrict<CR>
au VimEnter * nn <silent> <leader>d <CMD>DebugMode<CR>
```
改为：
```vim
au VimEnter * nn <silent> <leader>r <CMD>Run<CR>
au VimEnter * nn <silent> <leader>ir <CMD>Run<CR>
au VimEnter * nn <silent> <leader>d <CMD>Run -d<CR>
```
（`<leader>sr` RunModeStrict 移除——`-s` 逻辑改由用户在 `:Run` 命令字符串中自行控制。）

同时删除原 `RunModeWithArgs` 函数（原 335-338 行）——功能被 `:Run` 无参数 cmdline 预填取代：

```vim
# 删除：export def RunModeWithArgs() ... enddef
```

- [ ] **Step 3: 编译检查**

Run:
```bash
vim -u NONE -N -es -V1 -c "source /Users/macbook/Project/dotfiles/vim/functions/mode.vim" -c "qa!"
```
Expected: 无 E 开头错误。

- [ ] **Step 4: 验证 `:Run` 无参数行为（cmdline 预填）**

创建临时测试：
```bash
cat > /tmp/run_test.vim <<'EOF'
vim9script
source /Users/macbook/Project/dotfiles/vim/functions/mode.vim
# 模拟无参数：检查 autocmd 是否注册
au CmdwinEnter * ++once setline('.', 'Run io -m -eq %') | cursor(0, line('.'))
echo 'prefill registered'
EOF
vim -u NONE -N -es -V1 -c "source /tmp/run_test.vim" -c "qa!" 2>&1 | grep -v viminfo
rm -f /tmp/run_test.vim
```
Expected: 输出 `prefill registered`。cmdline 窗口实际交互行为需用户手动验证（`<leader>r` → cmdline 窗口 → 回车执行）。

- [ ] **Step 5: Commit**

```bash
git add vim/functions/mode.vim vimrc
git commit -m "feat(mode): add :Run command with default io -m -eq % and cmdline prefill
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 6: 全面编译验证 + 清理

**Files:**
- Modify: `vim/functions/mode.vim`（清理死代码、修复编译）
- Modify: `vimrc`（GrepMode 静态调用改为实例）

**目标：** 确保整个文件编译通过，清理遗留静态引用与死代码，更新所有调用点。

- [ ] **Step 1: 全文件编译检查**

Run:
```bash
vim -u NONE -N -es -V1 -c "source /Users/macbook/Project/dotfiles/vim/functions/mode.vim" -c "qa!"
```
Expected: 无 E 开头错误。

- [ ] **Step 2: 检查并清理遗留的静态引用**

搜索所有 `GrepMode\.` 引用是否已全部改为实例方式：
```bash
grep -n "GrepMode\." /Users/macbook/Project/dotfiles/vim/functions/mode.vim
```
Expected: 只剩类内 `this.xxx` / `CommandRunner.xxx` / `ModeManager.GetGrepMode(...)` 形式的引用，**不应有** `GrepMode.job`、`GrepMode.Grep()` 等直接静态成员访问（除非是类自身定义）。

搜索 vimrc 中的 GrepMode 引用：
```bash
grep -n "GrepMode" /Users/macbook/Project/dotfiles/vimrc
```
原 vimrc 中 `<leader>g` 绑定为：
```vim
au VimEnter * nn <silent> <leader>g <CMD>GrepModeOper<CR>g@
au VimEnter * vn <silent> <leader>g <CMD>GrepModeOper<CR>g@
au VimEnter * nn <silent> <leader>ig <CMD>GrepModeEdit<CR>q:
```
其中 `GrepModeOper`/`GrepModeEdit` 是 mode.vim 定义的命令（原 637-644 行），命令体内部引用 `GrepMode.Run()`/`GrepMode.GREP_*`——需改为实例。若 grep 结果含 `GrepMode.Run` / `GrepMode.GREP_` 报错，修改 mode.vim 中这两个命令：

```vim
command GrepModeOper {
    final gm = ModeManager.GetGrepMode(ModeManager.GetTabID())
    &operatorfunc = gm.Run()
}

command GrepModeEdit {
    final gm = ModeManager.GetGrepMode(ModeManager.GetTabID())
    echom (["Grep", gm.GREP_OPTION, gm.GREP_SEARCH_CONTENT, gm.GREP_SEARCH_PATH] + gm.GREP_OTHER_OPTION)
    autocmd CmdwinEnter * ++once setline('.', (["Grep", gm.GREP_OPTION, escape(gm.GREP_SEARCH_CONTENT, '/ '), gm.GREP_SEARCH_PATH] + gm.GREP_OTHER_OPTION)->join(' ')) | cursor(0, line('.'))
}
```

**注意：** 命令定义体（`{...}`）中不能使用 `final`（命令体是 `:execute` 上下文？实际命令体 `{}` 中可用 vim9 变量声明，但需确认）。若报错，改用函数封装：
```vim
def GrepModeOper()
    final gm = ModeManager.GetGrepMode(ModeManager.GetTabID())
    &operatorfunc = gm.Run()
enddef
command GrepModeOper GrepModeOper()
```
同理 GrepModeEdit。**以编译通过为准。**

- [ ] **Step 3: 清理死代码**

检查并移除（若存在）：
- 原 `GrepMode` 的 `GetQFbufnr`（如果已不再使用）
- `Mode` 基类中未使用的注释代码
- `RunMode` 中不再需要的 `Debug()` 方法（若 `:Run -d` 已完全接管）——**保留** `ModeManager.Debug` 入口，因为 `:Run -d` 调用它

删除测试产生的临时文件：
```bash
rm -f /tmp/vim9_*.vim /tmp/*_out.txt
```

- [ ] **Step 4: 最终编译 + 全量语法检查**

```bash
# mode.vim 编译
vim -u NONE -N -es -V1 -c "source /Users/macbook/Project/dotfiles/vim/functions/mode.vim" -c "qa!"
# vimrc 语法（会加载插件，可能因环境报插件错误——只关注 mode.vim 相关错误）
vim -u NONE -N -es -V1 -c "so /Users/macbook/Project/dotfiles/vimrc" -c "qa!" 2>&1 | grep -i "mode.vim"
```
Expected: 第一条无错误；第二条若输出空（无 mode.vim 相关错误）即通过。

- [ ] **Step 5: Commit**

```bash
git add vim/functions/mode.vim vimrc
git commit -m "chore(mode): cleanup dead code and fix remaining GrepMode static references
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 7: 手动功能验证清单（需用户在真实 Vim 中执行）

**Files:** 无（验证）

**目标：** 在真实 Vim 会话中验证 `:Run` 及四个 mode 的功能不回归。

- [ ] **Step 1: 用户在 Vim 中执行功能验证**

用户打开一个 `.py` 文件后依次执行并确认：

| 验证项 | 操作 | 预期 |
|--------|------|------|
| `:Run` 无参数 | `<leader>r` | 打开 cmdline 窗口，预填 `Run io -m -eq %`，回车执行 io |
| `:Run` 自定义 | `:Run python3 %` | term 窗口运行 python3 当前文件 |
| `:Run -d` 自定义 | `:Run -d python3 %` | job 模式，输出进 quickfix |
| `:Grep` 回归 | `<leader>g` 选中文本 | 搜索进入 quickfix |
| `:Grep` 参数 | `:Grep -n foo .` | 按 ParseGrepArgs 解析执行 |
| `:MypyMode` | 编辑 python 文件 | 保存后 5 秒自动检查 |
| 快捷键导航 | mode 中 `<c-n>`/`<c-p>` | 在 quickfix 中上下跳转 |
| 退出 mode | `<c-q>` 或切换 mode | ModeExit 正常，无残留 job/term/buffer |
| tab 隔离 | 开两个 tab 分别进入不同 mode | 各自状态独立 |

- [ ] **Step 2: 验证 `%` 占位符替换**

在 python 文件执行 `:Run echo %`，预期输出当前文件绝对路径。

- [ ] **Step 3: 记录验证结果**

用户将验证结果（通过/失败及现象）反馈，如有失败，回到对应 Task 修复后重新验证。

---

## Self-Review 记录

**Spec 覆盖检查：**
- ✅ CommandRunner 基类（字段/方法/可覆盖钩子）→ Task 1
- ✅ RunMode term 模式 + `io -m -eq %` 默认 → Task 3
- ✅ DebugMode job 模式 + `&makeprg` → Task 3
- ✅ GrepMode 实例化改造 → Task 2
- ✅ MypyMode timer 文件监听 → Task 4
- ✅ TabPage 持有四个实例 → Task 3
- ✅ ModeManager 分发保持 → Task 3
- ✅ `:Run` 命令（无参预填/自定义/-d）→ Task 5
- ✅ `%` 占位符替换 → Task 1（BuildCommand）/ Task 5
- ✅ GrepMode 静态改实例（vimrc + MypyMode + ParseGrepArgs）→ Task 2/6
- ✅ 保留功能：TimeStamp、_DecideSrc、错误文件、buffer 清理、grep_buffer_limit、operator → 各 Task
- ✅ 测试策略 → Task 1-6 编译检查 + Task 7 手动验证

**占位符检查：** 无 TBD/TODO；所有代码步骤给出完整代码。`RunCmd` 备选名作为 E174 异常处理路径已说明。

**类型一致性检查：**
- `CommandRunner.new(tabid, run_mode, cmd_template)` 与各子类 `super_new(tabid, run_mode, cmd_template)` 签名一致
- `super.ModeInit()` 返回 `bool`，各子类正确处理
- `Execute(...args): bool` / `RunJob(...args): bool` / `RunTerm(...args): bool` 基类与子类签名一致（`override` 需同名同签名）
- `ModeManager.Get*Mode(tabid): <Type>` 与 TabPage 字段类型一致
- `ParseRunArgs`/`ParseGrepArgs` 使用 `ModeManager.Get*Mode` 返回实例，属性访问一致
