vim9script
import "./higherorder.vim" as fp
# def BlankIndent(){{{


def UpdateSearchReg()
    if mode() !=# 'v'
        autocmd! HLSearch
        return
    endif
    const [_, row0, col0, _] = getcharpos("v")
    const [_, row1, col1, _] = getcharpos(".")
    var start_row: number
    var start_col: number
    var end_row: number
    var end_col: number
    if row0 * 10 + col0 < row1 * 10 + col1
        start_row = row0
        start_col = col0
        end_row   = row1
        end_col   = col1
    else
        start_row = row1
        start_col = col1
        end_row   = row0
        end_col   = col0
    endif

    if start_row ==# end_row
        SearchArgumentText(getline(start_row)[start_col - 1 : end_col - 1])
    elseif end_row - start_row ==# 1
        const first_line  = getline(start_row)
        const second_line = getline(end_row)
        SearchArgumentText(first_line[start_col - 1 : ] .. "\n" .. second_line[ : end_col - 1])
    else
        const first_line  = getline(start_row)
        const second_line = getline(end_row)
        const other_line  = getline(start_row  + 1, end_row - 1)
        SearchArgumentText(first_line[start_col - 1 : ] .. "\n" .. other_line->join("\n") .. "\n" .. second_line[ : end_col - 1])
    endif
enddef


export def HLSearch()
    @/ = ''
    aug HLSearch
    au CursorMoved * UpdateSearchReg()
    aug end
enddef

class BlankIndentDrawer
    static const indent_range: number = g:indent_range
    static const indentHl: dict<string> = {
        '1': 'Green',
        '2': 'Blue',
        '3': 'Purple',
        '4': 'Yellow',
        '5': 'modemsg',
        '6': 'VertSplit'
    }
    var nr_lst:  list<number> = []
    var row_lst: list<number> = []
    var win_id: number = -1
    var last_indent_num: number = -1

    def new(nr_lst: list<number>, win_id: number)
        this.nr_lst = nr_lst
        this.win_id = win_id
        this.row_lst = []
        this.last_indent_num = -1
    enddef

    def ClearPrevHl()
        this.nr_lst->fp.Map((_, nr: number) => {
            matchdelete(nr, this.win_id)
            # redraw
            # sleep 10m
        })
        this.nr_lst = []
        this.row_lst = []
    enddef

    def DrawCurrIndentLine(row: number, indent_num: number)
        if indent_num / 4 <= 0 || indent_num / 4 > 6
            return
        endif
        const indent_level = indent_num / 4
        const start_col    = (indent_num % 4 == 0) ? indent_num - 3 : (indent_level * 4 + 1)
        const hlgroup      = (indent_num % 4 == 0) ? BlankIndentDrawer.indentHl[indent_level] : 'Red'
        const nrs = range(max([1, row - BlankIndentDrawer.indent_range]), min([row + BlankIndentDrawer.indent_range, line('$')]))
        ->fp.Filter((_, linenr: number) => indent(linenr) >=# indent_num)
        ->fp.Reduce((pre: list<list<number>>, curr: number): list<list<number>> => {
            if len(pre[-1]) ==# 0
                return [[curr]]
            elseif curr - pre[-1][-1] >=# 2
                return pre->add([curr])
            else
                pre[-1]->add(curr)
                return pre
            endif
            }, [[]])
        ->fp.Reduce((pre: list<number>, curr: list<number>): list<number> => {
            if pre->index(row) ==# -1
                return curr
            else
                return pre
            endif
        }, [])
        ->fp.Map((_, nr: number): number => {
            this.nr_lst->add(matchaddpos(hlgroup, [[nr, start_col]]))
            return nr
            # redraw
            # sleep 10m
        })
        this.row_lst->extend(nrs)
    enddef

    def Draw()
        const [_, row, col, _] = getcharpos('.')
        const indent_num = indent('.')
        if this.row_lst->index(row) !=# -1 && indent_num ==# this.last_indent_num
            return
        endif
        this.ClearPrevHl()
        this.DrawCurrIndentLine(row, indent_num)
        this.last_indent_num = indent_num
    enddef
endclass

export class BlankIndentDrawerManager
    static var drawer_book: dict<BlankIndentDrawer> = {}

    static def Draw()
        const winid = win_getid()
        if keys(BlankIndentDrawerManager.drawer_book)->index(string(winid)) ==# -1
            BlankIndentDrawerManager.drawer_book[winid] = BlankIndentDrawer.new([], winid)
        endif
        BlankIndentDrawerManager.drawer_book[winid].Draw()
    enddef
endclass

# }}}

export def MakeSession()
    const dir  = "~/.cache/vim/session/"
    const filename = system("date +'%Y-%m-%T' \| tr -d '\n'") .. '.vim'
    if finddir('session', expand('~') .. '/.cache/vim') ==# ''
        mkdir(expand('~') .. '/.cache/vim/session', 'p')
    endif
    execute 'mksession! ' .. dir .. filename
    Notify(['保存session到', dir .. filename])
enddef



export def RecoverSession()
    const dir = '~/.cache/vim/session/'
    const cmd = '/usr/bin/ls --sort time '
    const sessions = system(cmd .. dir)->split('\n')
    popup_menu(sessions, {
        'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        'highlight': 'Notify',
        'title': 'Session List',
        'callback': (_, result: number): void => {
            if result !=# -1
                execute 'source ' .. dir .. sessions[result - 1]
            endif
        }
    })
enddef

def GetcWORD(waste: string): string
    const [_, row, col, _] = getcharpos('.')
    const line = getline('.')
    return CwordHelper(col - 3, line, '[[:ident:].]')
enddef


def SplitByDot(cword: string): list<string>
    if cword !~# '\.'
        return [cword]
    else
        return cword->split('\.')
    endif
enddef

def GetFuncname(waste: number, str: string): dict<dict<dict<any>>>
    const funcname = matchstr(str, '\v\i*\ze\(')
    return {[funcname]: {[str]: {}}}
enddef

class MethodBase
    static var file: dict<any> = json_decode(readfile("/home/rongzi/.vim/dictionary/method.json")->fp.Reduce((pre, curr) => pre .. curr, ''))

    static def AddToFile(keys_: list<string>, result: dict<any>)
        def Helper(sofar_keys: list<string>, sofar: dict<any>)
            if len(sofar_keys) ==# 1
                sofar[sofar_keys[0]] = result
            else
                if has_key(sofar, sofar_keys[0]) ==# 0
                    sofar[sofar_keys[0]] = {}
                endif
                Helper(sofar_keys[1 : ], sofar[sofar_keys[0]])
            endif
        enddef
        def GetKeys(packtree: dict<any>): list<string>
            if len(packtree) ==# 0
                return []
            else
                final keywords = []
                # var key: string
                # var value: dict<any>
                for [key, value] in packtree->items()
                    keywords->extend(GetKeys(value))
                    keywords->add(key)
                endfor
                return keywords
            endif
        enddef
        Helper(keys_, MethodBase.file)
        writefile([json_encode(MethodBase.file)], '/home/rongzi/.vim/dictionary/method.json')
        writefile(GetKeys(MethodBase.file), '/home/rongzi/.vim/dictionary/methods.txt')
    enddef

    static def Query(keys_: list<string>): dict<any>
        const result1 = MethodBase.Prop(keys_, MethodBase.file)
        if len(result1) !=# 0
            return result1
        endif
        # Notify(['跳过， 没有'])
        const result2 = MethodBase.Prop(['java', 'lang'] + keys_, MethodBase.file)
        if len(result2) !=# 0
            return result2
        endif
        return {}
    enddef

    static def Prop(keys_: list<string>, sofar: dict<any>): dict<any>
        # echom sofar
        if len(keys_) ==# 0
            return {}
        elseif sofar->has_key(keys_[0]) ==# 0
            return {}
        elseif len(keys_) ==# 1
            return sofar[keys_[0]]
        else
            return MethodBase.Prop(keys_[1 : ], sofar[keys_[0]])
        endif
    enddef
endclass

export def UpdateToDataBase()
    const package_name = input("包名: ")
    const methods = Javap(package_name)
    if len(methods) !=# 0
        MethodBase.AddToFile(package_name->split('\.'), methods)
    endif
enddef
# func ShowCompleteInfo(info)
    # let id = popup_findinfo()
    # if id
        # call popup_settext(id, 'async info: ' .. a:info)
        # call popup_show(id)
    # endif
# endfunction

def Javap(class: string): dict<any>
    const GetOrigin   = (waste: string) => system('javap -cp ~/Program/java ' .. class .. ' 2>&1 | grep -Pv "错误|Compiled|[{}]" | sed "s/^ *//g"')->split('\n')
    const ParseLine   = fp.Mapped(GetFuncname)
    const MakeDict    = fp.Reduced((pre: dict<any>, curr: dict<any>) => {
        const key = keys(curr)[0]
        if keys(pre)->index(key) !=# -1
            pre[key] = pre[key]->extend(curr[key])
        else
            pre->extend(curr)
        endif
        return pre
    }, {})
    const MakeNewDict = fp.Compose(GetOrigin, ParseLine, MakeDict)
    return MakeNewDict(class)
enddef

def ExtractCompletionItem(query_result: dict<any>): list<dict<any>>
    return query_result
        ->items()
        ->fp.Map((_, item: list<any>): dict<any> => {
        return { word: item[0],
            icase: 1,
            menu: item[1]
                ->keys()
                ->fp.Reduce((pre: string, curr: string): string => pre .. ' ' .. curr, '')}
            # kind: typename(item[1]) ==# 'dict<dict<any>>' ? fp.Reduce(keys(item[1])[0]->split(' '), GetType, "public") : ""
        })
enddef


def MethodCompletion(): dict<any>
    const ParseCurrClass    = fp.Compose(GetcWORD, SplitByDot)
    const keys_under_cursor = ParseCurrClass('')
    const withoutPrefix     = MethodBase.Query(keys_under_cursor)
    if withoutPrefix !=# {}
        return withoutPrefix
    endif
    const lines = getline(1, &lines)
    const GetInclude = (...wastes): list<list<string>> => {
        return lines
            ->fp.Map((_, v: string): string => matchstr(v, '\vimport +\zs[[:ident:].]*\ze\..*;'))
            ->fp.Filter((_, v: string): bool => len(v) !=# 0)
            ->fp.Map((_, v: string): list<string> => SplitByDot(v))
    }

    return GetInclude()
        ->fp.Map((_, v: list<string>): list<string> => v + keys_under_cursor)
        ->fp.Map((_, v: list<string>): dict<any> => MethodBase.Query(v))
        ->fp.Reduce(fp.ExtendDict, {})
enddef

def GetType(sig_pre: string, sig_curr: string): string
    if ["public", "static", "protected"]->index(sig_pre) !=# -1
        return sig_curr
    else
        try
            return {
            'int':              '𝗜',
            'Integer':          '𝗜',
            'char':             'ℂ',
            'java.lang.String': '𝖲',
            'float':            '𝔽',
            'double':           '𝔻',
            'void':             '∅',
            'boolean':          '𝔹',
            'long':             '𝕃'
            }[sig_pre]
        catch /.*/
            return sig_pre
        endtry
        return sig_pre
    endif
enddef


export def DisplayComplete(findstart: number, base: string): any
    if findstart ==# 1
        return col('.')
    else
        return {
            words: ExtractCompletionItem(MethodCompletion()),
            refresh: 1}
    endif
enddef

# function FileType(file){{{
export def FileType(file: string): string
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
# }}}

# function Icons(){{{
def Icons(filename: string): string
    return system('exa --icons=always ' .. shellescape(resolve(filename)))->split()[0]
enddef

def IconsBatch(args: list<string>): list<string>
    return system('exa --icons=always --sort name ' .. args->join(' '))->split('\n')
enddef
# }}}

# function Complete() {{{
def CwordHelper(index: number, line: string, regex: string = '[[:keyword:].]'): string
    if index <# 0
        return ''
    elseif line[index] =~# regex
        return CwordHelper(index - 1, line, regex) .. line[index]
    else
        return ''
    endif
enddef

export def Cword(regex='[[:ident:]]'): string
    const [_, row, col, _] = getcharpos('.')
    const line = getline('.')
    return CwordHelper(col - 2, line, regex)
enddef

export def Complete()
    # Notify([string(complete_info(['mode', 'items', 'pum_visible', 'selected']))])
    # Notify([string(g:HaveCompletion)])
    # Notify([string(Cword())])
    if g:autocomplete ==# 0
        return
    elseif strcharlen(Cword()) <= 0
        g:HaveCompletion = 1
        return
    elseif g:HaveCompletion ==# 0
        return
    else
        const [popupvisiable, mode] = values(complete_info(['mode', 'pum_visible']))
        if popupvisiable ==# 1
            return
        elseif mode ==# 'keyword'
            g:HaveCompletion = 0
            return
        elseif mode ==# 'function'
            # feedkeys("\<c-x>\<c-z>\<c-n>")
        elseif mode ==# ''
            feedkeys("\<c-n>")
        endif
    endif
enddef

export def DotComplete()
    set completefunc=DisplayComplete
    feedkeys("\<c-x>\<c-u>")
enddef

# }}}

# {{{ rust type
def RustType(findstart: number, base: string): any
    if findstart ==# 1
        return col('.')
    else
        return {
            words: [
            {'word': 'f32',
             'kind': 'f32',
             'abbr': '𝔽'
            },
            {'word': 'f64',
             'kind': 'f64',
             'abbr': '𝔻'
            },
            {'word': 'char',
             'kind': 'char',
             'abbr': 'ℂ'
            },
            {'word': 'i32',
             'kind': 'i32',
             'abbr': '𝗜'
            },
            {'word': 'i64',
             'kind': 'i64',
             'abbr': '𝕃'
            },
            {'word': 'bool',
             'kind': 'bool',
             'abbr': '𝔹'
            }],
            refresh: 1}
    endif
enddef
export def RustTypeCompletion()
    set completefunc=RustType
    feedkeys("\<c-x>\<c-u>")
enddef
# }}}

# function Strip() {{{
def Strip(source: string, char: string, direction: string = ''): string
    if direction !=# 'right'
        if source[0] ==# char
            return source[1 : ]->Strip(char, direction)
        else
            return source
        endif
    endif
    if direction !=# 'left'
        if source[- 1 : - 1] ==# char
            return source[ : - 2]->Strip(char, direction)
        else
            return source
        endif
    endif
    return 'Strip defulat return statement'
enddef

def Lstrip(source: string, char: string): string
    return Strip(source, char, 'left')
enddef

def Rstrip(source: string, char: string): string
    return Strip(source, char, 'right')
enddef
# }}}

# function AddSuffix(){{{
export def AddSuffix(char: string)
    const line: string = getline('.')->Rstrip(' ')
    if line[- 1 : - 1] ==# char
        Notify(['该位置已有 ' .. char])
        return
    endif

    setline('.', line .. char)
    normal! mS
    var message: string
    redir => message
    silent! marks S
    redir END
    Notify(['添加分号至', '']->extend(message->split("\n")))
enddef
# }}}

# function CR() {{{
export def CR()
    const [_, row: number, col: number, _] = getcharpos('.')
    const curr_line: string = getline(row)
    const next_line: string = getline(row + 1)

    setline(row, curr_line->Rstrip(' '))

    const indent: string = repeat(' ', cindent(row))
    if Rstrip(next_line, ' ') ==# ''
        setline(row + 1, indent)
    else
        put = indent .. ''
    endif
    setcursorcharpos(row + 1, len(indent) + 1)
enddef
# }}}

# function Notify() {{{
class Queue
    static var queue: list<number> = [0, &lines]
    var upper: number = 0
    var lower: number = &lines

    def new(this.upper, this.lower)
        Queue.queue[-1] = &lines
    enddef

    def ReleasePlace(base: number, size: number)
        Queue.queue = fp.Filter(Queue.queue,
                                (_, pos: number): bool => pos < base || pos >= base + size)
    enddef

    def _HoldPlace(base: number, size: number)
        Queue.queue = Queue.queue
                    ->extend(range(base, base + size - 1))
                    ->fp.Sort((a: number, b: number): number => a - b)

        const half: number = Queue.queue[- 1] / 2
    enddef

    def SearchSpaceReverse(size: number): number
        def SearchLower(pre: number, curr: number): number
            if Queue.queue->index(pre) ==# -1
                return pre
            elseif pre - curr - 1 >=# size
                return pre - size
            else
                return curr
            endif
        enddef
        return fp.Reduce(fp.Reversed(Queue.queue), SearchLower, this.lower)
    enddef

    def SearchSpace(size: number): number
        def SearchUpper(pre: number, curr: number): number
            if Queue.queue->index(pre) ==# -1
                return pre
            elseif curr - pre - 1 >=# size
                return pre + 1
            else
                return curr
            endif
        enddef
        return fp.Reduce(Queue.queue, SearchUpper, this.upper)
    enddef

    def Allocate(size: number, location: string): number
        # find the postion
        Queue.queue[-1] = &lines
        const base: number = {
            'up':   this.SearchSpace(size),
            'down': this.SearchSpaceReverse(size)
        }[location]

        if base + size ># Queue.queue[-1] || base <=# 0
            return 1
        else
            this._HoldPlace(base, size)
            return base
        endif
    enddef
endclass

final notify_queue = Queue.new(0, &lines)

export def Notify(texts: list<string>, location ='down', time = 800)
    def GetCol(): number
        const width: number = &columns
        const shift: number = max(fp.Map(texts, (_, val: string): number => len(val)))
        return width / 2 - shift / 2 + 3  # 这个3是用来微调的，删去也可以
    enddef
    const row: number = notify_queue.Allocate(len(texts) + 2, location)

    const options = {
        'col': GetCol(),
        'line': row,
        'time': time,
        'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        'callback': (id: number, index: number): void => notify_queue.ReleasePlace(row, len(texts) + 2)
    }
    popup_notification(texts, options)
enddef
# }}}

# function IntoLatex() {{{
export def IntoLatex(type: string)
    def AddDollar(line: string): string
        if line[0 : 1] ==# line[- 2 : - 1] && line[0 : 1] ==# '$$'
            Notify(['删去$$'], 'up')
            return line[2 : - 3]
        else
            Notify(['添加$$..i$$'], 'down')
            return "$$" .. line .. "$$"
        endif
    enddef
    const [min_nr: number, max_nr: number] = [getcharpos("'[")[1], getcharpos("']")[1]]
    getline(min_nr, max_nr)
        ->fp.Map((_, val: string): string => AddDollar(val))
        ->fp.Map((key, val: string): bool => setline(key + min_nr, val))
enddef
# }}}

# function Deleteterminal(){{{
export def DeleteTerminal()
    const Get_buffers  = (_): list<dict<any>> => getbufinfo({'bufloaded':  1})
    const Filter_term  = fp.Filtered((_, v: dict<any>): bool => v['name'] =~# '\v^!.*$')
    const Get_nr       = fp.Mapped((_, v): number => v['bufnr'])
    const Term_nrs     = fp.Compose(Get_buffers, Filter_term, Get_nr)

    const ToParam      = (nrs: list<number>): string => string(nrs)->substitute('\v[,\[\]'']', '', 'g')
    const Filter_none  = (param: string): string => len(param) ># 0 ?  'bd! ' .. param : ''
    const Make_command = fp.Compose(Term_nrs, ToParam, Filter_none)

    silent! exe Make_command(0)
enddef
# }}}

# function AddTableRow(){{{
export def AddTableRow(): string
    const pos:     list<number> = getcharpos('.')
    const columns: number = max([getline(pos[1])->count('|') - 1, 2])
    const column:  string    = ' <++> |'
    return range(columns)->reduce((old, new) => old .. column, '|')
enddef
# }}}


export class SearchStrategy
    static def Search(texts: list<list<string>>, part: string, row: number, col: number, step: number, nest_level: number, FoundOther: func(string, string): bool): list<number>
        const next_step = step ==# 0 ? 1 : - 1
        const Next_col  = (txts: list<list<string>>): number => step ==# 0 ? 1 : len(txts[step])
        var myrow   = row
        var mycol   = col
        var mylevel = nest_level
        while true
            if texts ==# [[]]
                return [-1, -1]
            endif
            if texts[step] ==# []
                texts->remove(step)
                myrow += next_step
                mycol =  Next_col(texts)
                continue
            endif
            # echom 'texts = ' .. string(texts[step]->join('')) .. " |myrow = " .. myrow .. "  mycol = " .. mycol .. "   mylevel = " .. mylevel .. '   part = ' .. part .. "   step = " .. step .. "  FoundOther(texts[step][step]) = " ..  FoundOther(texts[step][step], part)
            if FoundOther(texts[step][step], part)
                mylevel += 1
                texts[step]->remove(step)
                mycol += next_step
                continue
            elseif texts[step][step] ==# part && mylevel !=# 0
                mylevel -= 1
                texts[step]->remove(step)
                mycol += next_step
                continue
            elseif texts[step][step] ==# part && mylevel ==# 0
                return [myrow, mycol]
            else
                texts[step]->remove(step)
                mycol += next_step
                continue
            endif
        endwhile
        return [-1, -1]
    enddef

    static def SearchLeft(start_row: number, start_col: number, part: string, FoundOther: func(string, string): bool): list<number>
        const lower = max([start_row - Pair.range, 1])
        const upper = start_row
        var lines   = getline(lower, upper)
        var texts   = lines->fp.Map((_, v) => v->split('\zs'))
        if texts[-1] !=# []
            texts[-1]->insert('', start_col)
        else
            texts->insert('', 0)
        endif
        texts[-1]   = texts[-1][ : start_col]
        return SearchStrategy.Search(texts, part, start_row, start_col + 1, -1, 0, FoundOther)
    enddef

    static def SearchRight(start_row: number, start_col: number, part: string, FoundOther: func(string, string): bool): list<number>
        const lower = start_row
        const upper = start_row + Pair.range - 1
        var   lines = getline(lower, upper)
        var texts   = lines->fp.Map((_, v) => v->split('\zs'))
        if texts[0] !=# []
            texts[0]->insert('', start_col - 1)
        else
            texts->insert('', 0)
        endif
        texts[0]    = texts[0][start_col - 1 : ]
        return SearchStrategy.Search(texts, part, start_row, start_col - 1, 0, 0, FoundOther)
    enddef


    # SearchStrategy1
    static def InnerStrategy(left: string, right: string, start_row: number, start_col: number, FoundOther: func(string, string): bool): list<number>
        const [l_row, l_col] = SearchStrategy.SearchLeft(start_row,  start_col, left, FoundOther)
        const [r_row, r_col] = SearchStrategy.SearchRight(start_row, start_col + 1, right, FoundOther)
        return [l_row, l_col, r_row, r_col]
    enddef

    # SearchStrategy2
    static def LeftSideStrategy(left: string, right: string, start_row: number, start_col: number, FoundOther: func(string, string): bool): list<number>
        const [l_row, l_col] = SearchStrategy.SearchRight(start_row, start_col, left, FoundOther)
        if l_row <=# 0 || l_col <=# 0
            return [-1, -1, -1, -1]
        endif
        const [r_row, r_col] = SearchStrategy.SearchRight(l_row,     l_col + 1, right, FoundOther)
        return [l_row, l_col, r_row, r_col]
    enddef

    # SearchStrategy3
    static def RightSideStrategy(left: string, right: string, start_row: number, start_col: number, FoundOther: func(string, string): bool): list<number>
        const [r_row, r_col] = SearchStrategy.SearchLeft(start_row, start_col, right, FoundOther)
        if r_row <=# 0 || r_col <=# 0
            return [-1, -1, -1, -1]
        endif
        const [l_row, l_col] = SearchStrategy.SearchLeft(r_row,     r_col - 1,  left, FoundOther)
        return [l_row, l_col, r_row, r_col]
    enddef

    # SearchStrategy4
    static def Mix1(left: string, right: string, start_row: number, start_col: number, FoundOther: func(string, string): bool): list<number>
        var [l_row, l_col, r_row, r_col] = InnerStrategy(left, right, start_row, start_col, FoundOther)
        if l_row <=# 0 || l_col <=# 0 || r_row <=# 0 || r_col <=# 0
            [l_row, l_col, r_row, r_col] = LeftSideStrategy(left, right, start_row, start_col, FoundOther)
        endif
        if l_row <=# 0 || l_col <=# 0 || r_row <=# 0 || r_col <=# 0
            [l_row, l_col, r_row, r_col] = RightSideStrategy(left, right, start_row, start_col, FoundOther)
        endif
        return [l_row, l_col, r_row, r_col]
    enddef

    # SearchStrategy5
    static def Mix2(left: string, right: string, start_row: number, start_col: number, FoundOther: func(string, string): bool): list<number>
        var [l_row, l_col, r_row, r_col] = InnerStrategy(left, right, start_row, start_col, FoundOther)
        if l_row <=# 0 || l_col <=# 0 || r_row <=# 0 || r_col <=# 0
            return [l_row, l_col, r_row, r_col]
        else
            return RightSideStrategy(left, right, start_row, start_col, FoundOther)
        endif
    enddef

    # SearchStrategy6
    static def PreventSame(left: string, right: string, start_row: number, start_col: number, FoundOther: func(string, string): bool): list<number>
        const [l_row, l_col] = SearchStrategy.SearchLeft(start_row, start_col, left, FoundOther)
        const [r_row, r_col] = SearchStrategy.SearchRight(start_row, start_col + 1, right, FoundOther)
        if l_row ==# r_row
            return [l_row, l_col + 1, r_row, r_col - 1]
        else
            return [-1, -1, -1, -1]
        endif
    enddef

    # SearchStrategy7
    static def LeftSingleStrategy(left: string, right: string, start_row: number, start_col: number, FoundOther: func(string, string): bool): list<number>
        var [r_row, r_col] = SearchStrategy.SearchRight(start_row, start_col + 1, right, FoundOther)
        return [r_row, r_col]
    enddef

    # SearchStrategy8
    static def RightSingleStrategy(left: string, right: string, start_row: number, start_col: number, FoundOther: func(string, string): bool): list<number>
        var [l_row, l_col] = SearchStrategy.SearchLeft(start_row, start_col - 1, left, FoundOther)
        return [l_row, l_col]
    enddef

    # SearchStrategy10
    static def GiveUp(left: string, right: string, start_row: number, start_col: number, FoundOther: func(string, string): bool = (x: string, y: string) => false): list<number>
        return [-1, -1, -1, -1]
    enddef
endclass

class PositionMaker
    var row: number
    var col: number
    def new(expr: string)
        const [_, row, col, _] = getpos(expr)
        this.row = row
        this.col = col
    enddef
endclass

export class Position
    var row: number
    var col: number

    def new(row: number, col: number)
        this.row = row
        this.col = col
    enddef
    def Valid(): bool
        return this.row >= 1 && this.col >= 1
    enddef
    def Distance(anchor: Position): number
        const big_bit   = abs(anchor.row - this.row)
        const small_bit = abs(anchor.col - this.col)
        return big_bit * 10 + small_bit
    enddef
    static def Compare(anchor: Position, pos1: Position, pos2: Position): number
        return pos1.Distance(anchor) - pos2.Distance(anchor)
    enddef
endclass

export class Pair
    static const range: number = g:pair_range
    var left:  string
    var right: string
    var l_pos: Position
    var r_pos: Position
    var hightlightnrs: list<number> = []

    def new(left: string, right: string, start_row: number, start_col: number, SearchS: func = SearchStrategy.InnerStrategy)
        this.left      = left
        this.right     = right
        const start_pos = Position.new(start_row, start_col)
        if !start_pos.Valid()
            throw "Pair: new: start_pos is not valid!"
            return
        endif
        const [l_row, l_col, r_row, r_col] = SearchS(left, right, start_row, start_col, this.GetFoundOther())
        this.l_pos     = Position.new(l_row, l_col)
        this.r_pos     = Position.new(r_row, r_col)
    enddef

    def newByPos(left: string, right: string, l_pos: Position, r_pos: Position)
        this.left = left
        this.right = right
        if !l_pos.Valid() || !r_pos.Valid()
            throw "Pair: newByPos: l_pos or r_pos is not valid!"
        endif
        this.l_pos = l_pos
        this.r_pos = r_pos
    enddef

    def newLeftSingle(left: string, right: string, l_pos: Position)
        this.left  = left
        this.right = right
        this.l_pos = l_pos
        const [row, col] = SearchStrategy.LeftSingleStrategy(left, right, this.l_pos.row, this.l_pos.col, this.GetFoundOther())
        this.r_pos = Position.new(row, col)
    enddef

    def newRightSingle(left: string, right: string, r_pos: Position)
        this.left  = left
        this.right = right
        this.r_pos = r_pos
        const [row, col] = SearchStrategy.RightSingleStrategy(left, right, this.r_pos.row, this.r_pos.col, this.GetFoundOther())
        this.l_pos = Position.new(row, col)
    enddef

    def newEmpty()
        this.l_pos = Position.new(-1, -1)
        this.r_pos = Position.new(-1, -1)
        this.left  = ''
        this.right  = ''
    enddef

    def Empty()
        this.l_pos = Position.new(-1, -1)
        this.r_pos = Position.new(-1, -1)
        this.left  = ''
        this.right  = ''
    enddef

    def Valid(): bool
        return this.l_pos.Valid() && this.r_pos.Valid()
    enddef

    def Show()
        echom [[this.l_pos.row, this.l_pos.col], [this.r_pos.row, this.r_pos.col]]
    enddef

    def Highlight()
        this.hightlightnrs->add(matchaddpos('MatchParen', [[this.r_pos.row, getline(this.r_pos.row)->stridx(this.right, this.r_pos.col - 1) + 1]]))
        this.hightlightnrs->add(matchaddpos('MatchParen', [[this.l_pos.row, getline(this.l_pos.row)->stridx(this.left,  this.l_pos.col - 1) + 1]]))
    enddef

    def HighlightClear()
        this.hightlightnrs->fp.Map((_, nr: number) => matchdelete(nr))
        this.hightlightnrs = []
    enddef

    def SameRow(): bool
        return this.l_pos.row ==# this.r_pos.row
    enddef

    def Distance(anchor: Position): number
        return min([this.l_pos.Distance(anchor), this.r_pos.Distance(anchor)])
    enddef

    def Segment(): number
        return this.l_pos.Distance(this.r_pos)
    enddef

    def Contains(pos: Position): bool
        return this.l_pos.row <=# pos.row && pos.row <=# this.r_pos.row && this.l_pos.col <=# pos.col && pos.col <=# this.r_pos.col
    enddef

    def Equal(other: Pair): bool
        return this.left ==# other.left && this.right ==# other.right && this.l_pos.Distance(other.l_pos) ==# this.r_pos.Distance(other.r_pos) && this.l_pos.Distance(other.l_pos) ==# 0
    enddef

    def GetFoundOther(): func(string, string): bool
        def FoundOther(other: string, part: string): bool
            if this.left ==# this.right
                return false
            elseif [other, part] ==# [this.left, this.right]
                return true
            elseif [part, other] ==# [this.left, this.right]
                return true
            else
                return false
            endif
        enddef
        return FoundOther
    enddef
endclass

const part_dict = g:MATCHPAIRS
    ->fp.Map((_, partlist: list<string>): dict<list<string>> => {
        if ( partlist[0] == partlist[1] )
            return { [partlist[0]]: partlist}
        else
            return { [partlist[0]]: partlist, [partlist[1]]: partlist }
        endif
    })->reduce((pre: dict<list<any>>, curr: dict<list<any>>): dict<list<any>> => {
        pre->extend(curr)
        return pre
    })

const part_list = g:MATCHPAIRS
    ->fp.Reduce((pre, curr) => pre + curr, [])

const GetPair = (char: string): list<string> => {
    if ( keys(part_dict)->index(char) != -1 )
        return part_dict[char]
    else
        return []
    endif
}

const GetOther = (char: string): string => {
    return {
        '{': '}',
        '}': '{',
        '(': ')',
        ')': '(',
        '<': '>',
        '>': '<',
        '[': ']',
        ']': '[',
        '"': '',
        "'": ""}[char]
}

class PairMotionStrategyFactory
    static def MakeStrategy(char: string): func(Pair)
        if char ==# 'd'
            return (_pair: Pair) => {
                PairMotionStrategy.DeletePair(_pair)
                Notify(['删除' .. _pair.left .. _pair.right], 'down', 1000)
            }
        elseif char ==# 'c'
            const new_char = input('请输入一个字符')
            return (_pair: Pair) => {
                PairMotionStrategy.ChangePair(_pair, new_char, new_char)
                Notify(['替换为' .. [new_char, new_char]->join(' ')], 'down', 1000)
            }
        elseif GetPair(char) != []
            const [left, right] = GetPair(char)
            return (_pair: Pair) => {
                PairMotionStrategy.ChangePair(_pair, left, right)
                Notify(['替换为' .. [char, char]->join(' ')], 'down', 1000)
            }
        else
            return (_pair: Pair): void => {
                Notify(['未表示的motion'], 'down', 2000)
            }
        endif
    enddef
endclass


export def Match(): list<Pair>
    final line = getline('.')->split('\zs')
    const [_, row, col, _] = getcharpos('.')
    const GetPossibleIndexs = fp.Compose(
                    fp.Mapped((_, v: string): list<number> =>
                        fp.IndexAll(line, v)),
                    fp.Reduced((pre: list<number>, curr: list<number>) =>
                        (pre + curr), []),
                    fp.Filtered((_, v: number): bool => v !=# -1),
                    fp.Sorted((a: number, b: number): number => {
                        return abs(1 + a - col) - abs(1 + b - col)
                    })
                )

    const MakePair = (_, v: number): Pair => {
                        const a_pair     = GetPair(line[v])
                        const a_pair_pos = Position.new(row, v + 1)
                        if line[v] ==# a_pair[0]
                            return Pair.newLeftSingle(a_pair[0], a_pair[1], a_pair_pos)
                        else
                            return Pair.newRightSingle(a_pair[0], a_pair[1], a_pair_pos)
                        endif
                    }
    const SortPair = (a: Pair, b: Pair, target_pos: Position): number => {
        const closest = a.Distance(target_pos) - b.Distance(target_pos)
        if ! a.Contains(target_pos) && ! b.Contains(target_pos)
            return closest
        elseif a.Contains(target_pos) && b.Contains(target_pos)
            return closest
        elseif a.Contains(target_pos)
            return -1
        else
            return 1
        endif
    }

    const GuessPairs = fp.Compose(
                    GetPossibleIndexs,
                    (index_list: list<number>): list<Pair> => {
                        for i in index_list
                            const pair = MakePair('', i)
                            if pair.Valid()
                                return [pair]
                            endif
                        endfor
                        return []
                    })
    return GuessPairs(part_list)
enddef

export class MatchPairManager
    static var pairs_book: dict<list<Pair>> = {}

    static def GetPairByWinid(winid: number): list<Pair>
        if MatchPairManager.pairs_book->keys()->index(string(winid)) == -1
            return []
        else
            return MatchPairManager.pairs_book[winid]
        endif
    enddef

    static def ClearPairByWinid(winid: number)
        MatchPairManager.pairs_book[winid] = []
    enddef

    static def PairHighlightClear(winid: number)
        MatchPairManager.GetPairByWinid(winid)
            ->fp.Map((_, pair: Pair) => pair.HighlightClear())
        MatchPairManager.ClearPairByWinid(winid)
    enddef

    static def AddHighLightPair(winid: number, pair: Pair)
        pair.Highlight()
        MatchPairManager.pairs_book[winid]->add(pair)
    enddef

    static def LastPair(winid: number): Pair
        if len(MatchPairManager.GetPairByWinid(winid)) ==# 0
            throw "no more pair in manager"
        endif
        return MatchPairManager.pairs_book[winid][-1]
    enddef

    static def GotoLeft()
        const winid = win_getid()
        if len(MatchPairManager.GetPairByWinid(winid)) == 0
            return
        endif
        const pair = MatchPairManager.pairs_book[winid][0]
        setcursorcharpos(pair.l_pos.row, pair.l_pos.col)
    enddef

    static def GotoRight()
        const winid = win_getid()
        if len(MatchPairManager.GetPairByWinid(winid)) == 0
            return
        endif
        const pair = MatchPairManager.pairs_book[winid][0]
        setcursorcharpos(pair.r_pos.row, pair.r_pos.col)
    enddef

    static def GotoAnther()
        const winid = win_getid()
        if len(MatchPairManager.GetPairByWinid(winid)) == 0
            return
        endif
        const [_, row, col, _] = getcharpos('.')
        const pos = Position.new(row, col)
        if MatchPairManager.GetPairByWinid(winid)[0].l_pos.Distance(pos) ==# 0
            MatchPairManager.GotoRight()
        else
            MatchPairManager.GotoLeft()
        endif
    enddef

    static def PercentSign(order: number = -1)
        const [_, row, col, _] = getcharpos('.')
        const line = getline('.')
        const winid = win_getid()
        const pairs = Match()

        if keys(MatchPairManager.pairs_book)->index(string(winid)) ==# -1
            MatchPairManager.pairs_book[winid] = []
        endif
        if ( len(pairs) ==# 0 )
            MatchPairManager.PairHighlightClear(winid)
            return
        endif
        if len(MatchPairManager.GetPairByWinid(winid)) !=# 0 && MatchPairManager.LastPair(winid).Equal(pairs[0])
            return
        endif

        MatchPairManager.PairHighlightClear(winid)
        MatchPairManager.AddHighLightPair(winid, pairs[0])
    enddef
endclass

export def PercentSign1()
    const pairs = Match()
    if len(pairs) <=# 0
        return
    endif
    const pair = pairs[0]
    if pair.Segment() ==# 1
        setcursorcharpos(pair.l_pos.row, pair.l_pos.col)
        normal! aa
        setcursorcharpos(pair.l_pos.row, pair.l_pos.col + 1)
        normal! v
        setcursorcharpos(pair.r_pos.row, pair.r_pos.col)
        return
    endif
    if mode() ==# 'v'
        normal! v
    endif
    if !pair.SameRow() && strcharlen(getline(pair.l_pos.row)) ==# pair.l_pos.col
        setcursorcharpos(pair.l_pos.row + 1, 1)
    else
        setcursorcharpos(pair.l_pos.row, pair.l_pos.col + 1)
    endif
    normal! v
    setcursorcharpos(pair.r_pos.row, pair.r_pos.col - 1)
    return
enddef

export def PercentSign2()
    const pairs = Match()
    if len(pairs) <=# 0
        return
    endif
    const pair = pairs[0]
    if mode() ==# 'v'
        normal! v
    endif
    setcursorcharpos(pair.l_pos.row, pair.l_pos.col)
    normal v
    setcursorcharpos(pair.r_pos.row, pair.r_pos.col)
    return
enddef

## function ReplacePairs(){{{
class PairMotionStrategy
    static def SetLines(pair: Pair, lines: list<string>)
        if len(lines) ==# 1
            setline(pair.l_pos.row, lines[0])
        elseif len(lines) ==# 2
            setline(pair.l_pos.row, lines[0])
            setline(pair.r_pos.row, lines[1])
        else
            throw len(lines) <=# 2
        endif
    enddef

    static def DealBasicCase(pair: Pair, ProcessLeft: func(string): string, ProcessRight: func(string): string): list<string>
        if pair.SameRow()
            var   line    = getline(pair.l_pos.row)
            const Process = fp.Compose(ProcessRight, ProcessLeft)
            return [Process(line)]
        else
            var pair1_line = getline(pair.l_pos.row)
            var pair2_line = getline(pair.r_pos.row)
            return [ProcessLeft(pair1_line), ProcessRight(pair2_line)]
        endif
    enddef

    static def DeletePairProcess(pair: Pair): list<string>
        const ProcessRight = (line: string): string => {
            var ans = line->split('\zs')
            ans->remove(pair.r_pos.col - 1, pair.r_pos.col - 2 + strcharlen(pair.right))
            return ans->join('')
        }
        const ProcessLeft = (line: string): string => {
            var ans = line->split('\zs')
            ans->remove(pair.l_pos.col - 1, pair.l_pos.col - 2 + strcharlen(pair.left))
            return ans->join('')
        }
        return PairMotionStrategy.DealBasicCase(pair, ProcessLeft, ProcessRight)
    enddef

    static def DeletePair(pair: Pair)
        # pair.Show()
        const lines = PairMotionStrategy.DeletePairProcess(pair)
        PairMotionStrategy.SetLines(pair, lines)
    enddef

    static def ChangePairProcess(pair: Pair, new_left: string, new_right: string): list<string>
        var lines = PairMotionStrategy.DeletePairProcess(pair)
        if len(lines) ==# 1
            var line = lines[0]->split('\zs')
            line->insert(new_left, pair.l_pos.col - 1)
            line->insert(new_right, pair.r_pos.col - 1)
            lines[0] = line->join('')
        else
            var line = lines[0]->split('\zs')
            line->insert(new_left, pair.l_pos.col - 1)
            lines[0] = line->join('')
            line = lines[1]->split('\zs')
            line->insert(new_right, pair.r_pos.col - 1)
            lines[1] = line->join('')
        endif
        return lines
    enddef

    static def ChangePair(pair: Pair, new_left: string, new_right: string)
        const lines = PairMotionStrategy.ChangePairProcess(pair, new_left, new_right)
        PairMotionStrategy.SetLines(pair, lines)
    enddef
endclass

export def ReplacePairs()
    const winid = win_getid()
    if len(MatchPairManager.GetPairByWinid(winid)) ==# 0
        Notify(['未发现组合对'])
        return
    endif
    const pair = MatchPairManager.LastPair(winid)
    setcursorcharpos(pair.l_pos.row, pair.l_pos.col)
    pair.Highlight()
    redraw
    const char  = getcharstr()
    PairMotionStrategyFactory.MakeStrategy(char)(pair)
    pair.HighlightClear()
enddef
# }}}

# function CheckBoxToggle(){{{
export def CheckBoxToggle()
    const [_, row: number, col: number, _]  = getcharpos('.')
    const line: string = getline('.')
    const [left: number, right: number] = [stridx(line, '['), stridx(line, ']')]
    if left ==# -1 || right ==# -1 || left >=# right
        Notify(['没有checkbox'])
        return
    endif
    const has_x: string = (stridx(line, 'x') < left || (stridx(line, 'x') > right) ? 'x' : '')
    setline(row, line[ : left] .. has_x .. line[right : ])
enddef
# }}}

# function SelectBuffer(){{{
export def SelectBuffer()
    const display_name: list<string> = getbufinfo({'buflisted': 1})
            ->fp.Filter((_, val) => val["name"][0] !=# "!" && val["name"] !=# '' && val["name"] !=# bufname())
            ->fp.Map((_, buf) => shellescape(buf["name"]))
            ->IconsBatch()
            ->insert('➡️ ' .. bufname() .. ' ⬅️ You Are Here', 0)

            # ->fp.Map((_, name) => shellescape(resolve(name)))
    # echom names
    # echom display_name
    # echom name_on_menu
    popup_menu(display_name, {
        'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        'highlight':   'Notify',
        'callback':    (_, result) => {
            if result !=# -1
                return display_name
                        ->fp.Map((_, name) => name->split( )[1])[result - 1]
                        ->SwitchBuffer()
            endif
        }
    })
enddef
# }}}

# function SwitchBuffer(file){{{
def SwitchBuffer(file: string)
    Notify(['跳转 ' .. file])
    if isdirectory(file)
        Notify([file .. ' 是目录，不能打开'])
    elseif !filereadable(file)
        Notify([file .. ' 不可读，不能打开'])
    else
        silent execute 'buf ' .. file
    endif
enddef
# }}}

# function OpenBuffer(file){{{
def OpenBuffer(file: string)
    Notify(['跳转 ' .. file])
    if isdirectory(file)
        silent execute 'Lex ' .. file
    elseif !filereadable(file)
        Notify([file .. ' 不可读，不能打开'])
    else
        silent execute 'vsplit ' .. file
    endif
enddef
# }}}

# function SelectFile() {{{
def g:CreatePopup(buf_nr: number)
    popup_create(buf_nr, {
        'minwidth':    130,
        'minheight':   30,
        'border':      [1, 1, 1, 1],
        'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        'highlight':   'Notify'
    })
enddef

# use fzf to select files quickly
def PopupTerm(cmd: string, RestWork: func(job, number, dict<any>): void): void
    final buf_info: dict<any> = {}
    autocmd TerminalOpen * ++once call g:CreatePopup(str2nr(expand('<abuf>')))
    buf_info['bufnr'] = term_start(cmd, {
        'hidden': 1,
        'norestore': 1,
        'exit_cb': (job: job, result: number) => RestWork(job, result, buf_info)})
enddef

export def FZFfile()
    def SelectFile(fzf_job: job, result: number, buf_info: dict<any>)
        term_wait(buf_info['bufnr'])
        const lines = getline(1, &lines)
        close
        execute 'bdelete! ' .. buf_info['bufnr']
        if lines ==# ['']
            return
        endif
        fp.Map(lines, (_, filepath) => OpenBuffer(filepath))
    enddef
    PopupTerm($HOME .. '/.config/scripts/fzf_for_vim.sh', SelectFile)
enddef
# }}}
#
# function JoshutoSelectFile(){{{
export def JoshutoSelectFile()
    const tmp = tempname()
    def Rest_work(joshuto_job: job, result: number, buf_info: dict<any>)
        close
        execute 'bd! ' .. buf_info['bufnr']
        const content = readfile(tmp)
        if len(content) ==# 0
            Notify(['取消跳转'], 'up')
        endif
        fp.Map(content, (_, file: string) => OpenBuffer(file))
        system("rm -rf " .. tmp)
    enddef
    const cmd = $HOME .. '/.config/scripts/joshuto_for_vim.sh ' .. tmp
    PopupTerm(cmd, Rest_work)
enddef
# }}}

# use another way to show chars when in console{{{
# }}}

# function ShowLastStatus() unknow{{{
def ShowLastStatus()
    if @% =~# '!.*'
        set laststatus=0
    else
        set laststatus=2
    endif
enddef
# }}}

# function ChangeDirectory()    quickly change to the directory the buffer lies in{{{
def ChangeDirectory()
    if expand("%") ==# '' || system("cd " .. expand("%")) =~# '.*没有.*' || system("cd " .. expand("%")) =~# '.*No such.*'
        return
    endif
    execute "cd" .. expand('%:p:h')
enddef

def ChangeSrc()
    if expand("%") ==# '' || system("cd " .. expand("%")) =~# '.*没有.*' || system("cd " .. expand("%")) =~# '.*No such.*' || expand('%') ==# 'popup'
        return
    endif
    execute "let $src = " .. shellescape(expand('%:p'))
enddef
# }}}

# function ToggleConcealLevel()   toggle conceal chars{{{

export def ToggleConcealLevel()
    const level = {'0': '1', '1': '3', '2': '3', '3': '0'}
    exe 'setlocal conceallevel=' .. level[string(&conceallevel)]
enddef
# }}}


# useful expample in help doc :h <expr>{{{


# ███████╗████████╗██████╗ ██╗███╗   ██╗ ██████╗
# ██╔════╝╚══██╔══╝██╔══██╗██║████╗  ██║██╔════╝
# ███████╗   ██║   ██████╔╝██║██╔██╗ ██║██║  ███╗
# ╚════██║   ██║   ██╔══██╗██║██║╚██╗██║██║   ██║
# ███████║   ██║   ██║  ██║██║██║ ╚████║╚██████╔╝
# ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝
# String related functions{{{

def Print(text: string, Hl: string)
    exe 'echohl ' .. Hl
    echom text
    echohl None
enddef

# function SearchSelectedText(){{{
export def SearchSelectedText()
    @/ = '\M' .. substitute(@", '\', '\\\\', 'g')
                ->substitute('\$', '\\$', 'g')
                ->substitute('\n', '\\n', 'g')
    # Notify(["模式:" .. strpart(@/, 0, winwidth(0) - 30)])
    setl hlsearch
enddef

def SearchArgumentText(text: string)
    @/ = '\M' .. substitute(text, '\', '\\\\', 'g')
                ->substitute('\$', '\\$', 'g')
                ->substitute('\n', '\\n', 'g')
    # Notify(["模式:" .. strpart(@/, 0, winwidth(0) - 30)])
enddef

# }}}

# function InsertString(string, row, col){{{
def InsertString(content: string, row: number, col: number)
    # insert a string to (row, col), by default in the current buffer
    var line = getline(row)
    line->split('\zs')
        ->insert(content, min([col - 1, len(line)]))
        ->join('')
        ->setline(row)
enddef
# }}}
# }}}}}}


#  ██████╗ ██████╗ ███████╗██████╗  █████╗ ████████╗ ██████╗ ██████╗
# ██╔═══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗
# ██║   ██║██████╔╝█████╗  ██████╔╝███████║   ██║   ██║   ██║██████╔╝
# ██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗██╔══██║   ██║   ██║   ██║██╔══██╗
# ╚██████╔╝██║     ███████╗██║  ██║██║  ██║   ██║   ╚██████╔╝██║  ██║
#  ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝
# self defined operators {{{
# function VisualWrapper(left, ...)  wrap the selected text with char{{{
export def VisualWrapper()
    const start_pos = getcharpos("'<")
    const end_pos   = getcharpos("'>")

    echohl Function
    var left  = input("左侧分隔符: ")
    var right = input("右侧分隔符: ")
    echohl none
    right = (strcharlen(right) ==# 0) ? left : right

    InsertString(right, end_pos[1],   end_pos[2] + 1)
    InsertString(left,  start_pos[1], start_pos[2])
    setcursorcharpos(start_pos[1], start_pos[2])
enddef

# }}}
export def WrapOper(type: string, left: string, right: string, stop: number)
    const start_row = line("'[")
    const start_col = charcol("'[")
    const end_row   = line("']")
    const end_col   = charcol("']")
    echom type

    if type ==# 'char'
        InsertString(right, end_row,   end_col + 1)
        InsertString(left,  start_row, start_col)
    elseif type ==# 'block'
        InsertString(right, end_row,   end_col + 1)
        InsertString(left,  start_row, start_col)
        setcursorcharpos(end_row, end_col + 1 + ((start_row ==# end_row) ? len(left) : 0))
        execute "normal! i\<CR>\<Esc>l"
        setcursorcharpos(start_row, start_col + len(left))
        execute "normal! i\<CR>\<Esc>l"
    elseif type ==# 'line'
        echom "end_row " .. end_row .. " start_row " .. start_row
        const leading_space: string = ' '->repeat(indent(start_row))
        append(end_row,       leading_space .. right)
        append(start_row - 1, leading_space .. left)
        getline(start_row + 1, end_row + 1)->map((i: number, line: string): number => {
            if len(line) !=# 0
                setline(start_row + 1 + i, repeat(' ', &shiftwidth) .. line)
            endif
            return 1
        })
    endif

    if stop ==# 1
        setcursorcharpos(start_row, start_col)
        return
    endif
    # where stop == 2 case
    if type ==# 'char'
        if start_row ==# end_row
            setcursorcharpos(end_row, end_col + 2)
        else
            setcursorcharpos(end_row, end_col + 1)
        endif
    elseif type ==# 'block'
        setcursorcharpos(end_row, end_col + 2)
    elseif type ==# 'line'
        setcursorcharpos(end_row + 1, indent(end_row + 1))
    endif
enddef


# function SendKeys(type)  {{{
export def SendKeys(type: string)
    const [_, start_row, start_col, _] = getcharpos("'[")
    const [_, end_row,   end_col,   _] = getcharpos("']")
    if type ==# 'line'
        getline(start_row, end_row)
            ->fp.Filter((_, v: string): bool => len(v) ># 0)
            ->fp.Map((_, v: string): string => system('tmux send-keys -t {next} ' .. shellescape(v) .. "\r"))
    elseif type ==# 'block'
        getline(start_row, end_row)
            ->fp.Filter((_, v: string): bool => len(v) ># 0)
            ->fp.Map((_, a: string): string => a[start_col - 1 : end_col - 1])
            ->fp.Map((_, v: string): string => system('tmux send-keys -t {next} ' .. shellescape(v) .. "\r"))
    else
        const content = getline(start_row)[start_col - 1 : end_col - 1]
        system('tmux send-keys -t {next} ' .. shellescape(content) .. "\r")
    endif
enddef
# }}}

def AddOrDelComment(line: string, comment: string): string
    if comment ==# ''
        return line
    elseif line ==# ''
        return ''
    elseif line[0] ==# ' '
        return ' ' .. AddOrDelComment(line[1 : ], comment)
    elseif line[0] ==# comment[0]
        const comment_len = strcharlen(comment)
        const line_len    = strcharlen(line)
        if line[ : comment_len - 1] ==# comment
            const has_space = (line_len > comment_len  && line[comment_len] ==# ' ') ? 1 : 0
            return line[comment_len + has_space : ]
        endif
    endif
    return comment .. ' ' .. line
enddef


# function CommentToggle()  {{{
export def CommentToggleMaker(comment: string): void
    &operatorfunc = CommentToggle
enddef

def CommentToggle(type: string): void
    const [pos, min_number, max_number] = [getcharpos("']"), getcharpos("'[")[1], getcharpos("']")[1]]
    getline(min_number, max_number)
        ->fp.Map((key, val) => AddOrDelComment(val, g:comment))
        ->fp.Map((key, val) => setline(key + min_number, val))
enddef
# }}}


# function AddSeprator(){{{
export def BracketIndent(): void
    const [_, row, col, _]  = getcharpos('.')
    const line = getline(row)->Rstrip(' ')
    Notify(["call once"])
    if line[-1] ==# '{'

    else
        if line ==# '' && row == 1
            setline(row, repeat(' ', indent(row)) .. '{')
        elseif line ==# '' && row != 1
            const need_indent = getline(row - 1)[-1] ==# '{'
            if need_indent
                setline(row, repeat(' ', indent(row - 1) + &tabstop) .. '{')
            else
                setline(row, repeat(' ', indent(row - 1)) .. '{')
            endif
        else
            setline(row, line .. ' {')
        endif
    endif
    if getline(row + 1) =~# '^ *$'
        setline(row + 1, repeat(' ', indent(row)) .. '}')
    else
        put = repeat(' ', indent(row)) .. '}'
        normal! k
    endif
    CR()
    feedkeys("\<tab>")
enddef
# }}}

# nn <buffer> <silent> ; mqA;<Esc>`q

# function Quick_CD(){{{
export def Quick_CD(): void
    const input = expand(input("要跳转的目录:  "))
    const cmd   = 'locate -l 1 ' .. shellescape(input)
    const path  = system(cmd)->Rstrip('\n')
    if path ==# ''
        Print('没找到', 'Error')
        return
    endif

    if isdirectory(path)
        chdir(path)
        Print("当前处在 " .. substitute(system('pwd'), '\n', '', 'g'), 'Preproc')
    else
        const dir = path->split('/')[ : - 2]->join('/')
        if isdirectory(dir)
            chdir(dir)
        endif
        exe "bo vsplit " .. path
    endif
enddef
# }}}

# quickfix-window-function {{{
# 从 v:oldfiles 来建立快速修复列表
# call setqflist([], ' ', {'lines' : v:oldfiles, 'efm' : '%f', 'quickfixtextfunc' : 'QfOldFiles'})
# func QfOldFiles(info)
    # 获取一段快速修复项目范围的相关信息
    # let items = getqflist({'id' : info.id, 'items' : 1}).items
    # let l = []
    # for idx in range(info.start_idx - 1, info.end_idx - 1)
        # 使用简化的文件名
      # call add(l, fnamemodify(bufname(items[idx].bufnr), ':p:.'))
    # endfor
    # return l
# endfunc
#block }}}


# delete ~/.viminfo when it is too big
if exists($HOME .. "/.viminfo") && getfsize($HOME .. "/.viminfo") ># 20000
    system('mv $HOME/.viminfo{,.$(date +%Y-%m-%dT%H:%M:%S%Z).bak} && echo >| $HOME/.viminfo')
endif

abstract class Result
    var inner_value: any
    var IsFailure: bool
endclass

class Success extends Result
    # unit :: a -> Success a
    def new(value: any)
        this.inner_value = value
        this.IsFailure = false
    enddef
endclass

class Failure extends Result
    # unit :: a -> Failure a
    def new(value: any)
        this.inner_value = value
        this.IsFailure = true
    enddef
endclass

def SafeGetLine(row: number): Result
    if row < 1 || row > line('$')
        return Failure.new("超出缓冲区范围")
    endif
    return Success.new(getline(row))
enddef

def SafeGetLines(start: number, end: number): Result
    if start < 1 || end > line('$')
        return Failure.new("超出缓冲区范围")
    endif
    return Success.new(getline(start, end))
enddef


def SearchRightCurlyBracket(row: number): Result
    const has_right_braket = getline(row, line('$'))
        ->filter((_, line) => line->split('\zs')->index("}") !=# -1)
        ->len() ==# 0
    if has_right_braket
        return Failure.new("没有右括号")
    endif
    return Success.new("有右括号")
enddef

def SearchLeftCurlyBracet(row: number): Result
    const lines_contains_bracket = getline(1, row)
        ->map((index, line) => {
            return line
                ->split('\zs')
                ->filter((_, char) => char ==# '{' || char ==# '}')
                ->map((_, char) => [index + 1, char])
        })
        ->flattennew(1)
        ->reverse()

    var right_count: number = 0
    for [line_num, char] in lines_contains_bracket
        if char ==# '{'
            if right_count ==# 0
                return Success.new(line_num)
            else
                right_count -= 1
            endif
        elseif char ==# '}'
            right_count += 1
        endif
    endfor
    return Failure.new("could not find it!")
enddef


def SearchCurlyBraket(): bool
    const [_, row, col, _] = getcharpos(".")
    if SearchRightCurlyBracket(row).IsFailure
        return false
    endif
    const left_bracket = SearchLeftCurlyBracet(row - 1)
    if left_bracket.IsFailure
        return false
    endif
    return matchstr(getline(left_bracket.inner_value), '\v^\s*match>') !=# ''
enddef

export def GuessExand(): string
    const token = Cword('[^[:space:]]')
    if token ==# ''
        return '= '
    else
        return ' = '
    endif
enddef


export def RustGuessExpand(): string
    const token = Cword('[^[:space:]]')
    if token =~# '\v^\d+$'
        return '..'
    elseif token =~# '\v\.\.$'
        return '='
    elseif SearchCurlyBraket()
        if token ==# ''
            return '=> '
        else
            return ' => '
        endif
    elseif token ==# ''
        return '= '
    elseif token[-1 : ] ==# ')'
        return " ->"
    else
        return ' = '
    endif
enddef

def CountTrailing(str: string): number
    const count = str->len() - trim(str, ' ', 2)->len() - 1
    echom "count = " .. count
    return count
enddef

export def CppGuessExpand(): string
    const token = Cword('\v.')
    if token =~# '\v\)\s+$'
        return "-> "
    elseif token[-1 : ] ==# ')'
        return " -> "
    elseif token ==# ''
        return '= '
    else
        return ' = '
    endif
enddef
