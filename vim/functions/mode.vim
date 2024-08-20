vim9script
# wrap
import autoload "/home/rongzi/.vim/functions/useful.vim" as useful
import autoload "/home/rongzi/.vim/functions/higherorder.vim" as fp


#  ███╗   ███╗ ██████╗ ██████╗ ███████╗███████╗
#  ████╗ ████║██╔═══██╗██╔══██╗██╔════╝██╔════╝
#  ██╔████╔██║██║   ██║██║  ██║█████╗  ███████╗
#  ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝  ╚════██║
#  ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗███████║
#  ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝

# self defined modes {{{

def WinFocusOn(winid: number)
    if len(getwininfo(winid)) ==# 0
        useful.Notify(['WinFocusOn: 没有' .. winid .. ' 这个id的窗口'])
        echom 'WinFocusOn: 没有' .. winid .. ' 这个id的窗口'
        return
    endif
    const origin_winnr = getwininfo(winid)[0]['winnr']
    execute ':' .. origin_winnr .. ' wincmd w'
enddef

def JumpTo(mark: string)
    if getcharpos("'" .. mark) ==# [0, 0, 0, 0]
        useful.Notify(['JumpTo: 没有' .. mark .. ' 这个标签可以跳转'])
        return
    endif
    execute 'normal! `' .. mark ..  'zz'
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
        nn <c-q> <ScriptCmd>ModeManager.ExitMode(t:tabid)<CR>
        return true
    enddef

    def ModeExit()
        WinFocusOn(this.origin_winid)
        JumpTo(this.tag)
        # silent! execute 'nunmap q'
        silent! execute 'delmarks ' .. this.tag
    enddef
endclass

class MypyMode
    public var tabid: number
    public var job:   job
    public var mode:  Mode
    public var timer_id: number
    public var filepath: string
    public var mtime: number = 0

    def new(tabid: number)
        this.tabid = tabid
        this.mode  = Mode.new(tabid)
    enddef

    def ModeExit()
        # job_stop(this.job, 'kill')
        timer_stop(this.timer_id)
        cclose
        this.mode.ModeExit()
    enddef

    def Copen()
        exe 'botright copen' .. string(float2nr(&lines * (3.0 / 14.0)))
        setlocal nonumber norelativenumber nolist
        execute "normal! \<c-w>k"
    enddef

    def ModeInit(): bool
        this.filepath = expand('%:p')
        if useful.FileType(this.filepath) !=# 'python'
            return false
        endif
        this.mode.ModeInit()
        nn <c-n> <ScriptCmd> GrepMode.Cnext()<CR>
        nn <c-p> <ScriptCmd> GrepMode.Cprev()<CR>
        cgetexpr ''
        return true
    enddef

    def Run()
        if this.ModeInit() ==# false
            useful.Notify(['ModeInit失败，不进入MypyMode'])
            return
        endif
        def RunMypy(timer_id: number, ...args: list<any>)
            const ftime = getftime(this.filepath)
            # echom ['dmypy', 'check', this.filepath]
            if ftime ==# this.mtime
                return
            endif
            this.mtime = ftime
            if this.job !=# null && job_status(this.job) ==# 'run'
                job_stop(this.job, 'kill')
            endif
            cgetexpr ''
            this.job = job_start(['dmypy', 'check', this.filepath], {'callback': MypyMode.RunHandler})
        enddef
        this.timer_id = timer_start(5 * 1000, RunMypy, {'repeat': -1})
        this.Copen()
    enddef

    static def RunHandler(ch: channel, msg: string)
        caddexpr msg
    enddef

endclass

export class GrepMode
    public static var job: job
    public static var count: number
    public static var grep_buffer_limit: number
    public static final mode = Mode.new(0)
    public static var loaded_buf_nr: list<number> = []

    static def Cnext()
        try
            cnext
        catch
            useful.Notify(['没有下一项'])
        endtry
    enddef

    static def Cprev()
        try
            cprev
        catch
            useful.Notify(['没有上一项'])
        endtry
    enddef
    static def Copen(text: string)
        @/ = text
        exe 'botright copen ' .. string(float2nr(&lines * (3.0 / 14.0)))
        setlocal nolist nonu nornu
        # execute "normal! \<c-w>k"
    enddef

    static def ModeInit(): bool
        ModeManager.ExitMode(t:tabid)
        GrepMode.mode.ModeInit()
        nn <c-n> <ScriptCmd> GrepMode.Cnext() \| normal! zR<CR>
        nn <c-p> <ScriptCmd> GrepMode.Cprev() \| normal! zR<CR>
        &errorformat = &grepformat
        GrepMode.grep_buffer_limit = g:grep_buffer_limit
        GrepMode.loaded_buf_nr = getbufinfo({'buflisted': 1})->map((_, buf) => buf['bufnr'])
        ModeManager.database[string(t:tabid)].curr_mode = "GrepMode"
        return true
    enddef

    static def ModeExit()
        silent! cclose
        GrepMode.mode.ModeExit()
        job_stop(GrepMode.job)
        const Valid = (_, buf) => {
            return buf['windows'] ==# []
              && GrepMode.loaded_buf_nr->index(buf['bufnr']) ==# -1
              && bufnr(buf['bufnr']) !=# -1
        }
        # echom GrepMode.loaded_buf_nr
        getbufinfo({"buflisted": 1})->fp.Filter(Valid)
                    ->fp.Map((_, buf) => {
                        echom 'bdelete! ' .. buf['bufnr']
                        silent! execute 'bdelete! ' .. buf['name']
                        return 1
                    })
    enddef

    static def GrepHandler(ch: channel, msg: string)
        if GrepMode.grep_buffer_limit ==# 0
            job_stop(GrepMode.job)
            return
        endif
        GrepMode.grep_buffer_limit -= 1
        caddexpr msg

    enddef

    static def Run(): func: void
        return (_) => {
            const winid = win_getid()
            var searchContent: string = ""
            const [_, l_row, l_col, _] = getpos("'[")
            const [_, r_row, r_col, _] = getpos("']")
            if l_row ==# r_row
                const left_col  = min([l_col, r_col])
                const right_col = max([l_col, r_col])
                searchContent = getline(l_row)[left_col - 1 : right_col - 1]
            elseif l_row ># r_row
                var lines: list<string> = getline(r_row, l_row)
                lines[0]  = lines[0][r_col - 1 : ]
                lines[-1] = lines[-1][ : l_col - 1]
            elseif l_row <# r_row
                var lines: list<string> = getline(l_row, r_row)
                lines[0]  = lines[0][l_col - 1 : ]
                lines[-1] = lines[-1][ : r_col - 1]
            endif
            GrepMode.ModeInit()
            # 清除qf列表
            cgetexpr ''
            GrepMode.count = 0
            GrepMode.job = job_start(
                ["grep", "-rni", searchContent, expand("%:p"), expand("%:p:h")],
                {'out_cb': GrepMode.GrepHandler, 'timeout': 100})
            GrepMode.Copen(searchContent)
            WinFocusOn(winid)
        }
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

export def RunModeWithArgs()
    const args = input("请输入参数： ")
    ModeManager.Run(t:tabid, '--', args)
enddef

def AddFlag(flag: string): any
    return (condition: bool) => {
        if condition
           return ' ' .. flag
        else
            return ''
        endif
    }
enddef

export class RunMode
    public var term_nr: number
    public var run_job: job
    public var src_path: string
    public var debug_buffer_limit: number = 0
    public var makeprg: string
    public var tabid:   number
    public var mode: Mode
    public var open_term: bool = false

    def new(tabid: number)
        this.tabid = tabid
        this.mode  = Mode.new(tabid)
    enddef

    def ModeExit()
        this.mode.ModeExit()
        if job_status(this.run_job) !=# 'fail'
            job_stop(this.run_job, 'kill')
        endif
        if bufnr(this.term_nr) !=# -1 && this.term_nr !=# 0
            execute 'bdelete! ' .. this.term_nr
        endif
        if this.open_term
            cclose
        endif
    enddef

    def _DecideSrc(): string
        var curr_path = expand('%:p')
        if ['java', 'cpp', 'c', 'python', 'rust', 'bash', 'sh']->index(useful.FileType(curr_path)) !=# -1 && &buftype ==# ''
            this.makeprg = &makeprg
            this.mode.ModeInit()
            ModeManager.ExitMode(t:tabid)
            return curr_path
        endif
        ModeManager.ExitMode(t:tabid)
        curr_path = expand('%:p')
        if ['java', 'cpp', 'c', 'python', 'rust', 'bash', 'sh']->index(useful.FileType(curr_path)) !=# -1
            this.makeprg = &makeprg
            # this.mode.ModeInit()
            return curr_path
        endif

        useful.Notify(['只能运行Rust/C/Cpp/Python/Java文件'])
        return ''
    enddef

    def ModeInit(): bool
        this.src_path = this._DecideSrc()
        if this.src_path ==# ''
            echom "this.src_path = " .. string(this.src_path)
            return false
        endif
        this.mode.ModeInit()
        nn <c-n> <ScriptCmd> GrepMode.Cnext()<CR>
        nn <c-p> <ScriptCmd> GrepMode.Cprev()<CR>
        this.debug_buffer_limit = g:debug_buffer_limit
        if getfsize($HOME .. '/.cache/vim/error') >=# 1
            return true
        endif
        return true
    enddef

    static def Copen()
        botright copen 6
        exe 'botright copen ' .. string(float2nr(&lines * (3.0 / 14.0)))
        setlocal nonumber norelativenumber nolist
        # execute "normal! \<c-w>k"
    enddef

    static def ExitHandler(exit_job: job, winid: number, runmode: RunMode)
        const exitval = job_info(exit_job)['exitval']
        if [0, 130, -1]->index(exitval) !=# -1
            return
        endif
        useful.Notify(['编译运行错误'])
        if bufnr(runmode.term_nr) !=# -1 && bufnr(runmode.term_nr) !=# 0
            execute 'bdelete! ' .. runmode.term_nr
        endif

        if getfsize($HOME .. '/.cache/vim/error') >=# 1
            execute 'cgetfile ' .. $HOME .. '/.cache/vim/error'
            setqflist([], 'r',  {'title': '退出代码: ' .. string(exitval)})
            RunMode.Copen()
            runmode.open_term = true
        endif
    enddef

    def Run(...args: list<any>)
        if this.ModeInit() ==# false
            useful.Notify(['ModeInit失败，不进入RunMode'])
            return
        endif

        const winid = win_getid()
        var   run_only    = false
        const strict      = args->index('-s') !=# -1
        const input       = args->index('--') !=# -1
        const input_args  = input ? join(args[args->index('--') : ], ' ') : ''
        const option      = {'term_rows': &lines / 5, 'err_io': 'file', 'err_name': $HOME .. '/.cache/vim/error', 'exit_cb': (exit_job: job, id: number) => RunMode.ExitHandler(exit_job, id, this)}
        const time_passby = TimeStamp(false)
        const run_cmd     = "io -eq " .. this.src_path

        if time_passby <# 1.0
            run_only = 1
            useful.Notify(['运行过快,据上一次运行只有 ' .. time_passby .. 's'], 'up', float2nr((1.0 - time_passby) * 1000))
        endif

        const cmd = run_cmd .. AddFlag('-s')(strict) .. AddFlag('-r')(run_only) .. AddFlag(input_args)(input)
        botright this.term_nr = term_start(cmd, option)
        TimeStamp(!run_only)
        WinFocusOn(winid)
    enddef

    static def RunHandler(ch: channel, msg: string, runmode: RunMode)
        caddexpr msg
        runmode.debug_buffer_limit -= 1
        # echom runmode.debug_buffer_limit
        if runmode.debug_buffer_limit <=# 0
            ch_close(ch)
            caddexpr '超出最大缓冲区限制: ' .. g:debug_buffer_limit .. "  修改g:debug_buffer_limit以增大容量"
        endif
    enddef

    def Debug()
        if this.ModeInit() ==# false
            useful.Notify(['ModeInit失败，不进入RunMode'])
            return
        endif
        const winid = win_getid()
        const option   = {'callback': (ch: channel, msg: string) => RunMode.RunHandler(ch, msg, this),
            'exit_cb': (exit_job: job, msg: number) => {
                const exitval = job_info(exit_job)['exitval']
                setqflist([], 'r',  {'title': '退出代码: ' .. string(exitval)})
            }}
        const run_cmd  = this.makeprg
            ->split(' ')
            ->map((_, token) => (token =~# '\v\%.*') ? this.src_path : token)
            ->join(' ')
        this.run_job = job_start(run_cmd, option)
        RunMode.Copen()
        this.open_term = true
        WinFocusOn(winid)
    enddef
endclass
# }}}

class TabPage
    public var tabid: number
    public var curr_mode: string = ''
    public var run_mode:  RunMode
    public var mypy_mode: MypyMode

    def new(tabid: number)
        this.tabid = tabid
        this.curr_mode = ''
        this.run_mode  = RunMode.new(tabid)
        this.mypy_mode = MypyMode.new(tabid)
    enddef
    def SetCurrMode(mode_type: string)
        this.curr_mode = mode_type
    enddef
    def ExitMode()
        if this.curr_mode ==# ''
        elseif this.curr_mode ==# 'Mode'
            # mode_state.ModeExit()
        elseif this.curr_mode ==# 'GrepMode'
            GrepMode.ModeExit()
        elseif this.curr_mode ==# 'RunMode'
            this.run_mode.ModeExit()
        elseif this.curr_mode ==# 'MypyMode'
            this.mypy_mode.ModeExit()
        endif
        this.SetCurrMode('')
    enddef
endclass

export class ModeManager
    public static var tab_num: number = 1
    public static var database: dict<any> = {}

    static def Register(tabnr: number)
        # echom "Register: tabnr = " .. string(tabnr)
        const tabid = ModeManager.tab_num
        settabvar(tabnr, 'tabid', tabid)
        ModeManager.database[string(tab_num)] = TabPage.new(tabid)
        ModeManager.tab_num += 1
    enddef

    static def CheckOut(tabid: number)
        ModeManager.database->remove(string(tabid))
    enddef

    static def ExitMode(tabid: number)
        final mode_state: TabPage = ModeManager.database[string(tabid)]
        mode_state.ExitMode()
    enddef

    static def Run(tabid: number, ...args: list<any>)
        # echom 'tabid = ' .. string(tabid) .. '  keys = ' .. string(ModeManager.database->keys())
        final mode_state: TabPage = ModeManager.database[string(tabid)]
        if len(args) ==# 0
            mode_state.run_mode.Run()
        else
            mode_state.run_mode.Run(args[0], args[1 : ]->join(' '))
        endif
        mode_state.SetCurrMode('RunMode')
    enddef

    static def Debug(tabid: number)
        # echom 'tabid = ' .. string(tabid) .. '  keys = ' .. string(ModeManager.database->keys())
        final mode_state: TabPage = ModeManager.database[string(tabid)]
        mode_state.run_mode.Debug()
        mode_state.SetCurrMode('RunMode')
    enddef

    static def Mypy(tabid: number)
        final mode_state: TabPage = ModeManager.database[string(tabid)]
        mode_state.mypy_mode.Run()
        mode_state.SetCurrMode('MypyMode')
    enddef

endclass

# }}}
# defcompile
