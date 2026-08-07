vim9script

#  ███╗   ███╗ ██████╗ ██████╗ ███████╗███████╗
#  ████╗ ████║██╔═══██╗██╔══██╗██╔════╝██╔════╝
#  ██╔████╔██║██║   ██║██║  ██║█████╗  ███████╗
#  ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝  ╚════██║
#  ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗███████║
#  ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝

# self defined modes {{{

def FileType(file: string): string
    if file =~# '\v.*\.py$'
        return 'python'
    elseif file =~# '\v.*\.[ch]$'
        return 'c'
    elseif file =~# '\v.*\.cpp$'
        return 'cpp'
    elseif file =~# '\v.*\.java$'
        return 'java'
    elseif file =~# '\v.*\.rs$'
        return 'rust'
    elseif file =~# '\v.*\.sh$'
        return 'sh'
    elseif file =~# '\v.*\.bash$'
        return 'bash'
    else
        return 'else'
    endif
enddef

def WinFocusOn(winid: number)
    if len(getwininfo(winid)) ==# 0
        echom 'WinFocusOn: 没有' .. winid .. ' 这个id的窗口'
        echom 'WinFocusOn: 没有' .. winid .. ' 这个id的窗口'
        return
    endif
    const origin_winnr = getwininfo(winid)[0]['winnr']
    execute ':' .. origin_winnr .. ' wincmd w'
enddef

def JumpTo(mark: string)
    if getcharpos("'" .. mark) ==# [0, 0, 0, 0]
        echom 'JumpTo: 没有' .. mark .. ' 这个标签可以跳转'
        return
    endif
    execute 'normal! `' .. mark
enddef

export class Mode
    public var origin_winid: number
    public var tabid: number
    public var tag: string

    def new(tabid: number)
        this.tabid = tabid
        this.tag   = nr2char(this.tabid + 65)
    enddef

    def ModeInit(): bool
    # jump to last M mark if there already have M, otherwise set the M mark here
        execute 'normal! m' .. this.tag
        this.origin_winid = win_getid()
        nn <c-q> <ScriptCmd>ModeManager.ExitMode(ModeManager.GetTabID())<CR>
        return true
    enddef

    def ModeExit()
        WinFocusOn(this.origin_winid)
        JumpTo(this.tag)
        # silent! execute 'nunmap q'
        silent! execute 'delmarks ' .. this.tag
    enddef
endclass

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
        # 将 cmd_template 中的 '%' 替换为当前文件绝对路径（转义替换串特殊字符）
        return substitute(this.cmd_template, '%', escape(this.filepath, '&\~'), 'g')
    enddef

    def ModeInit(): bool
        # 保存快捷键 + 设置 filepath + 继承 Mode 的 mark 初始化
        const ok = super.ModeInit()
        this.filepath = expand('%:p')
        this.maping_ctrl_n = maparg('<c-n>', 'n', false, 1)
        this.maping_ctrl_p = maparg('<c-p>', 'n', false, 1)
        # 所有 mode 的 quickfix 导航快捷键（子类 ModeInit 会在 super 之后覆盖定义）
        nn <c-n> <ScriptCmd>CommandRunner.Cnext()<CR>
        nn <c-p> <ScriptCmd>CommandRunner.Cprev()<CR>
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

    static def Copen(height_ratio: float = 3.0 / 14.0)
        exe 'botright copen ' .. string(float2nr(&lines * height_ratio))
        setlocal nonumber norelativenumber nolist
    enddef

    static def Cnext()
        try
            cnext
        catch /E42\|E553/
            echom '没有更多错误'
        endtry
    enddef

    static def Cprev()
        try
            cprev
        catch /E42\|E553/
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

class MypyMode extends CommandRunner
    def new(tabid: number)
        # Vim9 无法调用 super.New()，手动初始化继承字段
        this.tabid = tabid
        this.tag   = nr2char(this.tabid + 65)
        this.run_mode     = 'job'
        this.cmd_template = 'dmypy check %'
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
        nn  <c-n> <ScriptCmd> CommandRunner.Cnext()<CR>
        nn  <c-p> <ScriptCmd> CommandRunner.Cprev()<CR>
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

    def Execute(...args: list<any>): bool
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
        # Vim9 无法调用 super.New()，手动初始化继承字段
        this.tabid = tabid
        this.tag   = nr2char(this.tabid + 65)
        this.run_mode     = 'job'
        this.cmd_template = ''
    enddef

    def ModeInit(): bool
        # 先退出其他 mode，再进入 GrepMode
        ModeManager.ExitMode(ModeManager.GetTabID())
        const ok = super.ModeInit()
        if !ok
            return false
        endif
        nn <c-n> <ScriptCmd>CommandRunner.Cnext() \| normal! zR<CR>
        nn <c-p> <ScriptCmd>CommandRunner.Cprev() \| normal! zR<CR>
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

    def RunJob(...args: list<any>): bool
        this.GREP_SEARCH_PATH = this.GREP_SEARCH_PATH->fnamemodify(":p:h")
        const cmd_list = [this.GREP_BIN, this.GREP_OPTION, this.GREP_SEARCH_CONTENT, this.GREP_SEARCH_PATH] + this.GREP_OTHER_OPTION
        echom cmd_list
        this.job = job_start(
            cmd_list,
            {'callback': (ch: channel, msg: string) => this.GrepHandler(ch, msg), 'timeout': 100})
        this.Copen()
        return true
    enddef

    def Grep()
        const winid = win_getid()
        this.ModeInit()
        this.count = 0
        this.RunJob()
        WinFocusOn(winid)
    enddef
endclass

# function RunMode(){{{
def MakeTimeStamp(): func(bool): float
    var last_run_time = 0.0
    def TimeStampInner(mkstamp: bool = true): float
        const old_time = last_run_time
        const new_time = reltimefloat(reltime())
        if mkstamp
            last_run_time = new_time
        endif
        return new_time - old_time
    enddef
    return TimeStampInner
enddef
var TimeStamp = MakeTimeStamp()
var term_bufnr: number = -1

def AddFlag(flag: string): any
    return (condition: bool) => {
        if condition
           return ' ' .. flag
        else
            return ''
        endif
    }
enddef

export class RunMode extends CommandRunner
    public var src_path: string

    def new(tabid: number)
        # Vim9 无法调用 super.New()，手动初始化继承字段
        this.tabid = tabid
        this.tag   = nr2char(this.tabid + 65)
        this.run_mode     = 'term'
        this.cmd_template = 'io -m -eq %'
    enddef

    def _ResolveSrc(): string
        var curr_path = expand('%:p')
        const types = ['java', 'cpp', 'c', 'python', 'rust', 'bash', 'sh']
        if &buftype ==# '' && types->index(FileType(curr_path)) !=# -1
            # 先退出其他 mode，再进入 RunMode
            ModeManager.ExitMode(ModeManager.GetTabID())
            return curr_path
        endif

        ModeManager.ExitMode(ModeManager.GetTabID())
        curr_path = expand('%:p')
        if types->index(FileType(curr_path)) !=# -1
            return curr_path
        else
            return ''
        endif
    enddef

    def ModeInit(): bool
        this.src_path = this._ResolveSrc()
        if this.src_path ==# ''
            return false
        endif
        return super.ModeInit()
    enddef

    def ModeExit()
        this.Stop()
        super.ModeExit()
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
            CommandRunner.Copen()
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

    def Run(...args: list<any>): bool
        return this.RunTerm(args)
    enddef
endclass

export class DebugMode extends CommandRunner
    public var src_path: string
    public var debug_buffer_limit: number = 0
    public var makeprg: string

    def new(tabid: number)
        # Vim9 无法调用 super.New()，手动初始化继承字段
        this.tabid = tabid
        this.tag   = nr2char(this.tabid + 65)
        this.run_mode     = 'job'
        this.cmd_template = ''
    enddef

    def ModeInit(): bool
        # 先退出其他 mode，再进入 DebugMode
        ModeManager.ExitMode(ModeManager.GetTabID())
        const curr_path = expand('%:p')
        const types = ['java', 'cpp', 'c', 'python', 'rust', 'bash', 'sh']
        if types->index(FileType(curr_path)) ==# -1
            return false
        endif
        this.src_path = curr_path
        this.makeprg = &makeprg
        const ok = super.ModeInit()
        if !ok
            return false
        endif
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

    def BuildCommand(): string
        # 若用户通过 ModeManager.Debug 提供了自定义命令则用之，否则用 &makeprg
        if this.cmd_template !=# ''
            return substitute(this.cmd_template, '%', escape(this.src_path, '&\~'), 'g')
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
# }}}

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

export class ModeManager
    public static var tab_num: number = 1
    public static var database: dict<any> = {}

    static def GetTabID(): number
        const id = gettabvar(0, "tabid", -1)
        if id !=# -1
            return id
        else
            return ModeManager.Register(0)
        endif
    enddef

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

    static def Register(tabnr: number): number
        const tabid = ModeManager.tab_num
        settabvar(tabnr, 'tabid', tabid)
        ModeManager.database[string(tab_num)] = TabPage.new(tabid)
        ModeManager.tab_num += 1
        return tabid
    enddef

    static def CheckOut(tabid: number)
        ModeManager.database->remove(string(tabid))
    enddef

    static def ExitMode(tabid: number)
        final mode_state: TabPage = ModeManager.database[string(tabid)]
        mode_state.ExitMode()
    enddef

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
        if mode_state.mypy_mode.Execute()
            mode_state.SetCurrMode('MypyMode')
        endif
    enddef

endclass

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

def ParseRunArgs(...args: list<string>)
    const tabid = ModeManager.GetTabID()
    if len(args) ==# 0
        # 无参数：注册 autocmd，由映射后的 q: 打开 cmdline 窗口并预填默认命令
        autocmd CmdwinEnter * ++once setline('.', 'Run io -m -eq %') | cursor(0, line('.'))
        return
    endif
    if args[0] ==# '-d'
        # debug 模式：job_start + quickfix
        ModeManager.Debug(tabid, args[1 : ]->join(' '))
        return
    endif
    # term 模式：自定义命令（% 在 BuildCommand 中替换为当前文件路径）
    ModeManager.Run(tabid, args->join(' '))
enddef


# 脚本级 operatorfunc：Vim9 实例方法返回的闭包（引用 this）经 g@ 调用会报 E1248，
# 故改用脚本级函数，内部通过 ModeManager.GetGrepMode 获取实例。
def GrepModeOperFunc(_type: string)
    const gm = ModeManager.GetGrepMode(ModeManager.GetTabID())
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
    gm.GREP_SEARCH_CONTENT = '\<' .. searchContent .. '\>'
    gm.Grep()
enddef

command GrepModeOper {
    &operatorfunc = function('GrepModeOperFunc')
}

# 脚本级变量：存储 cmdline 预填内容（autocmd 触发时命令体局部变量不可用，需用脚本级变量）
var g_grep_edit_prefill: string = ''

def GrepModeEditFunc()
    final gm = ModeManager.GetGrepMode(ModeManager.GetTabID())
    echom (["Grep", gm.GREP_OPTION, gm.GREP_SEARCH_CONTENT, gm.GREP_SEARCH_PATH] + gm.GREP_OTHER_OPTION)
    g_grep_edit_prefill = (["Grep", gm.GREP_OPTION, escape(gm.GREP_SEARCH_CONTENT, '/ '), gm.GREP_SEARCH_PATH] + gm.GREP_OTHER_OPTION)->join(' ')
    autocmd CmdwinEnter * ++once setline('.', g_grep_edit_prefill) | cursor(0, line('.'))
enddef

command GrepModeEdit GrepModeEditFunc()

# :Run 命令 —— 无参数由映射追加 q: 打开 cmdline 预填默认命令；-d 切 DebugMode(job)
command -nargs=* Run ParseRunArgs(<f-args>)
command -nargs=+ Grep ParseGrepArgs(<f-args>)
command -nargs=0 MypyMode        ModeManager.Mypy(ModeManager.GetTabID())



# }}}
# defcompile
