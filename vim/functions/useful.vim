vim9script
import "./higherorder.vim" as fp

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
    else
        return 'else'
    endif
enddef
# }}}

# function Icons(){{{
def Icons(filename: string): string
    return system('exa --icons=always ' .. shellescape(filename))->split()[0]
enddef
# }}}

# function Complete() {{{
def Cword(): string
    def CwordHelper(index: number, sofar: string, line: string): string
        if index <# 0
            return sofar
        elseif line[index] !~# '[[:keyword:]]'
            return sofar
        else
            return CwordHelper(index - 1, line[index] .. sofar, line)
        endif
    enddef

    const [_, row: number, col: number, _] = getcharpos('.')
    const line: string = getline('.')[ : col - 2] .. v:char
    return CwordHelper(col - 1, '', line)
enddef

export def Complete()
    if  pumvisible() ==# 0 && strcharlen(Cword()) >=# 2
        feedkeys("\<c-x>\<c-z>")
        feedkeys("\<c-n>")
    endif
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
    const pos:     list<number> = getpos('.')
    const columns: number = max([getline(pos[1])->count('|') - 1, 2])
    const column:  string    = ' <++> |'
    return range(columns)->reduce((old, new) => old .. column, '|')
enddef
# }}}


export class SearchStrategy
    static def Search(texts: list<any>, part: string, row: number, col: number, step: number, nest_level: number, FoundOther: func(string, string): bool): list<number>
        const next_step = step ==# 0 ? 1 : - 1
        const Next_row  = (txts) => step ==# 0 ? 1 : len(txts[step])
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
                mycol =  Next_row(texts)
                continue
            endif
            # echom 'texts = ' .. string(texts[step]->join('')) .. " |myrow = " .. myrow .. "  mycol = " .. mycol .. "   mylevel = " .. mylevel .. '   part = ' .. part .. "   step = " .. step .. "  FoundOther(texts[step][step]) = " ..  FoundOther(texts[step][step])
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
        var [r_row, r_col] = SearchStrategy.SearchRight(start_row, start_col, right, FoundOther)
        return Position.new(r_row, r_col)
    enddef

    # SearchStrategy8
    static def RightSingleStrategy(left: string, right: string, start_row: number, start_col: number, FoundOther: func(string, string): bool): list<number>
        var [l_row, l_col] = SearchStrategy.SearchRight(start_row, start_col, right, FoundOther)
        return Position.new(l_row, l_col)
    enddef

    # SearchStrategy9
    static def GiveUp(left: string, right: string, start_row: number, start_col: number, FoundOther: func(string, string): bool = (x: string, y: string) => false): list<number>
        return [-1, -1, -1, -1]
    enddef
endclass

export class Position
    var row: number
    var col: number

    def new(row: number, col: number)
        this.row = row
        this.col = col
    enddef
    def Distance(anchor = Position.new(1, 1)): number
        const big_bit   = abs(anchor.row - this.row)
        const small_bit = abs(anchor.col - this.col)
        return big_bit * 10 + small_bit
    enddef
    def Valid(): bool
        return this.row >= 1 && this.col >= 1
    enddef
    static def Compare(anchor = Position.new(1, 1), pos1 = Position.new(1, 1), pos2 = Position.new(1, 1)): number
        return pos1.Distance(anchor) - pos2.Distance(anchor)
    enddef
endclass

export class Pair
    static const range: number = 10
    var left:  string
    var right: string
    var l_pos: Position
    var r_pos: Position
    var start_pos: Position

    def new(left: string, right: string, start_row: number, start_col: number, SearchS: func = SearchStrategy.InnerStrategy)
        this.left      = left
        this.right     = right
        this.start_pos = Position.new(start_row,  start_col)
        if !this.start_pos.Valid()
            this.Empty()
            return
        endif
        const [l_row, l_col, r_row, r_col] = this.Search(SearchS)
        this.l_pos     = Position.new(l_row, l_col)
        this.r_pos     = Position.new(r_row, r_col)
    enddef

    def newLeftSingle(left: string, right: string, l_pos: Position)
        this.left  = left
        this.right = right
        this.l_pos = l_pos
        if !l_pos.Valid()
            this.Empty()
            return
        endif
        this.r_pos = SearchStrategy.LeftSingleStrategy(left, this.l_pos.row, this.l_pos.col, this.GetFoundOther())
    enddef
    def newEmpty()
        this.l_pos = Position.new(-1, -1)
        this.r_pos = Position.new(-1, -1)
        this.start_pos  = Position.new(-1, -1)
        this.left  = ''
        this.right  = ''
    enddef
    def Empty()
        this.l_pos = Position.new(-1, -1)
        this.r_pos = Position.new(-1, -1)
        this.start_pos  = Position.new(-1, -1)
        this.left  = ''
        this.right  = ''
    enddef
    def newRightSingle(left: string, right: string, r_pos: Position)
        this.left  = left
        this.right = right
        this.r_pos = r_pos
        this.l_pos = SearchStrategy.RightSingleStrategy(right, this.l_pos.row, this.l_pos.col, this.GetFoundOther())
    enddef

    def Valid(): bool
        return this.l_pos.Valid() && this.r_pos.Valid() && this.start_pos.Valid()
    enddef

    def Show()
        echom [[this.l_pos.row, this.l_pos.col], [this.r_pos.row, this.r_pos.col]]
    enddef

    def SameRow(): bool
        return this.l_pos.row ==# this.r_pos.row
    enddef

    def Search(Strateg: func): list<number>
        return Strateg(this.left, this.right, this.start_pos.row, this.start_pos.col, this.GetFoundOther())
    enddef

    def Distance(anchor = Position.new(0, 0)): number
        return min([this.l_pos.Distance(anchor), this.r_pos.Distance(anchor)])
    enddef

    def Segment(): number
        return this.l_pos.Distance(this.r_pos)
    enddef

    def Contains(pos: Position): bool
        return this.l_pos.row <=# pos.row && pos.row <=# this.r_pos.row && this.l_pos.col <=# pos.col && pos.col <=# this.r_pos.col
    enddef

    def ContainsStart(): bool
        return this.l_pos.row <=# this.start.row && this.start.row <=# this.r_pos.row && this.l_pos.col <=# this.start.col && this.start.col <=# this.r_pos.col
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

const MATCHPAIRS = [
    ['{', '}'],
    ['<', '>'],
    ['[', ']'],
    ['(', ')'],
    ["'", "'"],
    ['"', '"'],
    ['`', '`'],
    ['def', ")"]
]


const GetPair = (char: string): list<string> => {
    return {
        '{': ['{', '}'],
        '}': ['{', '}'],
        '(': ['(', ')'],
        ')': ['(', ')'],
        '<': ['<', '>'],
        '>': ['<', '>'],
        '[': ['[', ']'],
        ']': ['[', ']'],
        '"': ['"', '"'],
        '`': ['`', '`'],
        'def': ['def', ')'],
        "'": ["'", "'"]}[char]
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


export def Match(): list<Pair>
    const line = getline('.')->split('\zs')
    const [_, row, col, _] = getcharpos('.')
    const pos = Position.new(row, col)
    const GetPossibleIndexs = fp.Compose(
                    fp.Mapped((_, v: string): list<number> =>
                        fp.IndexAll(line, v)),
                    fp.Reduced((pre: list<number>, curr: list<number>) =>
                        (pre + curr), []),
                    fp.Filtered((_, v: number): bool => v !=# -1))

    const MakePair = (_, v: number): Pair => {
                        const a_pair = GetPair(line[v])
                        return Pair.new(a_pair[0], a_pair[1], row, v + 1, SearchStrategy.Mix1)
                    }

    const SortPair = (a: Pair, b: Pair, target_pos: Position) => {
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
                    fp.Mapped(MakePair),
                    fp.Filtered((_, v: Pair): bool => v.Valid()),
                    fp.Sorted((a: Pair, b: Pair): number => SortPair(a, b, pos)))
    return GuessPairs(fp.Reduce(MATCHPAIRS, (pre, curr) => pre + curr, []))
enddef

export def PercentSign(order: number = -1): Pair
    const pairs = Match()
    if len(pairs) <=# 0
        return Pair.new('_', '_', -1, -1, SearchStrategy.GiveUp)
    endif
    const pair = pairs[0]
    const [_, row, col, _] = getpos('.')
    const pos = Position.new(row, col)

    if pair.l_pos.Distance(pos) !=# 0 && order ==# -1
        setcursorcharpos(pair.l_pos.row, pair.l_pos.col)
    elseif pair.l_pos.Distance(pos) ==# 0 && order ==# -1
        setcursorcharpos(pair.r_pos.row, pair.r_pos.col)
    elseif order ==# 0
        setcursorcharpos(pair.l_pos.row, pair.l_pos.col)
    else
        setcursorcharpos(pair.r_pos.row, pair.r_pos.col)
    endif
    return pair
enddef

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
class ReplaceStrategy
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
        return ReplaceStrategy.DealBasicCase(pair, ProcessLeft, ProcessRight)
    enddef

    static def DeletePair(pair: Pair)
        # pair.Show()
        const lines = ReplaceStrategy.DeletePairProcess(pair)
        ReplaceStrategy.SetLines(pair, lines)
    enddef

    static def ChangePairProcess(pair: Pair, new_left: string, new_right: string): list<string>
        var lines = ReplaceStrategy.DeletePairProcess(pair)
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
        const lines = ReplaceStrategy.ChangePairProcess(pair, new_left, new_right)
        ReplaceStrategy.SetLines(pair, lines)
    enddef
endclass

def ReplacePairs()
    const pair = PercentSign()
    if !pair.Valid()
        pair.Show()
        Notify(['未发现组合对'])
        return
    endif
    setcursorcharpos(pair.l_pos.row, pair.l_pos.col)

    const char  = getcharstr()
    if char ==# 'd'
        ReplaceStrategy.DeletePair(pair)
        Notify(['删除' .. pair.left .. pair.right], 'down', 1000)
    elseif char ==# 'c'
        const new_char = input('请输入一个字符')
        ReplaceStrategy.ChangePair(pair, new_char, new_char)
        Notify(['替换为' .. [new_char, new_char]->join(' ')], 'down', 1000)
    else
        const [left, right] = GetPair(char)
        ReplaceStrategy.ChangePair(pair, left, right)
        Notify(['替换为' .. [char, char]->join(' ')], 'down', 1000)
    endif
enddef
nn gr <ScriptCmd>ReplacePairs()<CR>
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
    const names = getbufinfo({'buflisted': 1})
            ->fp.Filter((_, val) => val["name"][0] !=# "!")
            ->fp.Map((_, buf) => buf["name"])
    const icon_name = names->fp.Map((_, v: string) => Icons(v) .. ' ' .. v)
    popup_menu(icon_name, {
        'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        'callback': (_, result) => (result !=# -1) ? SwitchBuffer(names[result - 1]) : ''
    })
    # DeleteBuffer()
enddef
# }}}

# function SwitchBuffer(file){{{
def SwitchBuffer(file: string)
    Notify(['跳转 ' .. file])
    if isdirectory(file)
        Notify([file .. ' 是目录，不能打开'])
    else
        silent execute 'buf ' .. file
    endif
enddef
# }}}

# function OpenBuffer(file){{{
def OpenBuffer(file: string)
    Notify(['跳转 ' .. file])
    if isdirectory(file)
        Notify([file .. ' 是目录，不能打开'])
        # silent execute 'Explore ' . file " 似乎vim不能在pop_window打开的时候使用Explore
    else
        silent execute 'vsplit ' .. file
    endif
enddef
# }}}


# function JoshutoSelectFile(){{{
export def JoshutoSelectFile()
    def Rest_work(id: number, result: number, filename: string)
        silent! normal! `J
        delmarks J
        const content = readfile(filename)
        if len(content) ==# 0
            Notify(['取消跳转'], 'up')
            return
        endif
        fp.Map(content, (_, file: string) => OpenBuffer(file))
        system("rm -rf " .. filename)
    enddef

    const tmp = tempname()
    normal! mJ
    const term_buffer = term_start('/home/rongzi/.config/scripts/joshuto_for_vim.sh ' .. tmp, { 'hidden': 1, 'term_finish': 'close', 'norestore': 1 })
    const pop_window  = popup_create(term_buffer, {
        'minwidth': 90,
        'minheight': 25,
        'border': [1, 1, 1, 1],
        'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        'highlight': 'Notify',
        'callback': (id, result) => Rest_work(id, result, tmp)
    })
enddef
# }}}

# function SelectFile(){{{
# use fzf to select files quickly
export def SelectFile()
    def Rest_work(filename: string)
        const content = readfile(filename)
        if len(content) ==# 0
            Notify(['取消跳转'], 'up')
        endif
        fp.Map(content, (_, file: string) => OpenBuffer(file))
        system("rm -rf " .. filename)
    enddef

    const tmp         = tempname()
    const term_buffer = term_start('/home/rongzi/.config/scripts/fzf_for_vim.sh ' .. tmp, {'hidden': 1, 'term_finish': 'close', 'norestore': 1})
    const pop_window  = popup_create(term_buffer, {
        'minwidth': 130,
        'minheight': 20,
        'maxheight': 35,
        'border': [1, 1, 1, 1],
        'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        'highlight': 'Notify',
        'callback': (_, _) => Rest_work(tmp)
    })
enddef
# }}}

# function DeleteBuffer(){{{
def DeleteBuffer()
    var ls_out: string
    redir => ls_out
    silent! ls
    redir END
    for buf in ls_out->split('\n')
        var tokens: list<string> = buf->split(' ')
        if tokens[4] =~# '"!/home/rongzi/.config/scripts/.*'
            silent! execute 'bdelete ' .. tokens[0]
        endif
    endfor
enddef
# }}}

# use another way to show chars when in console{{{
# if $DISPLAY == ''
    # set notermguicolors
    # set fillchars=vert:\|
    # set listchars=leadmultispace:\|\ \ \ ,trail:-,precedes:>,extends:<,tab:\ \ 
    # color zellner
# endif
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
    Notify(["模式:" .. strpart(@/, 0, winwidth(0) - 30)])
    setl hlsearch
enddef

def SearchArgumentText(text: string)
    @/ = '\M' .. substitute(text, '\', '\\\\', 'g')
                ->substitute('\$', '\\$', 'g')
                ->substitute('\n', '\\n', 'g')
    Notify(["模式:" .. strpart(@/, 0, winwidth(0) - 30)])
    setl hlsearch
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
export function MakeWrapper(left = "(", right = ")", stop = 1)
    function! OperatorWrapper(type) closure
        let start_pos =  getcharpos("'[")
        let end_pos   =  getcharpos("']")
        let start_row =  start_pos[1]
        let start_col =  start_pos[2]
        let end_row   =  end_pos[1]
        let end_col   =  end_pos[2]
        function! WrapLine(line, line_number) closure
            if a:line ==# ''
                return ''
            endif
            vim9cmd InsertString(a:right, a:line_number, (a:type == 'line') ? strcharlen(a:line) + 1 : end_col + 1)
            vim9cmd InsertString(a:left,  a:line_number, (a:type == 'line') ? 1 : start_col)
        endfunction

        if a:type ==# 'char'
            vim9cmd InsertString(a:right, end_row,   end_col + 1)
            vim9cmd InsertString(a:left,  start_row, start_col)
        else
            call getline(start_row, end_row)->map('WrapLine(v:val, v:key + start_row)')
        endif

        if a:stop ==# 1
            call setcursorcharpos(start_row, start_col)
            return
        endif
        " where stop == 2 case
        if a:type ==# 'char'
            call setcursorcharpos(end_row, end_col + 1 + (start_row ==# end_row))
        elseif a:type ==# 'block'
            call setcursorcharpos(end_row, end_col + 2)
        elseif a:type ==# 'line'
            call setcursorcharpos(end_row, 2147483647)
        endif
    endfunction
    return funcref('OperatorWrapper')
endfunction

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
    put = repeat(' ', indent(row)) .. '}'
    normal! k
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

#  ███╗   ███╗ ██████╗ ██████╗ ███████╗███████╗
#  ████╗ ████║██╔═══██╗██╔══██╗██╔════╝██╔════╝
#  ██╔████╔██║██║   ██║██║  ██║█████╗  ███████╗
#  ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝  ╚════██║
#  ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗███████║
#  ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝
# self defined modes {{{
var origin_winid: number
var ExitModeFunc: func = () => 1

def ModeInit()
    # jump to last M mark if there already have M, otherwise set the M mark here
    execute 'normal! mM'
    origin_winid = win_getid()
    nn q <CMD>call <SID>ExitModeFunc() <CR>
enddef

def ExitMode()
    if len(getwininfo(origin_winid)) ==# 1
        const origin_winnr = getwininfo(origin_winid)[0]['winnr']
        execute ':' .. origin_winnr .. ' wincmd w'
    endif
    if getcharpos("'M") !=# [0, 0, 0, 0]
        execute 'normal! `Mzz'
    endif
    delmarks M
    silent! execute 'nunmap q'
    ExitModeFunc = () => {
        echom 'wtf'
        return 1
    }
enddef

var last_bufnr: number = -1
def Cnext()
    const curr_buffer_number = bufnr()
    if last_bufnr !=# -1 && curr_buffer_number !=# last_bufnr
        silent! execute "bdelete " ..  last_bufnr
    endif
    last_bufnr = curr_buffer_number
    silent! cnext
enddef
def Cprev()
    const curr_buffer_number = bufnr()
    if last_bufnr !=# -1 && curr_buffer_number !=# last_bufnr
        silent! exe "bdelete " ..  last_bufnr
    endif
    last_bufnr = curr_buffer_number
    silent! cprev
enddef

export def GrepOperator(type: string)
    var save_reg:   string
    def SaveReg()
       save_reg = @Y
    enddef
    def RestoreReg()
       @Y = save_reg
    enddef
    def Copen(text: string)
        SearchArgumentText(text)
        copen
        setlocal nolist nonu nornu
        execute "normal! \<c-w>k"
        redraw!
    enddef
    def ExitOperatorMode()
        silent! cclose
        RestoreReg()
        ExitMode()
        nn <c-n> <Cmd>bnext<CR>
        nn <c-p> <Cmd>bprev<CR>
    enddef
    def GrepOperatorInit()
        silent! ExitModeFunc()
        ModeInit()
        ExitModeFunc = ExitOperatorMode
        SaveReg()
        nn <c-n> <ScriptCmd> Cnext()<CR>
        nn <c-p> <ScriptCmd> Cprev()<CR>
    enddef

    # init the mode
    GrepOperatorInit()
    silent! normal! `<"ay`>

    Notify(["正在查找：" .. @a])
    silent! exe  'grep -Rsi ' .. shellescape(@a) .. " ."
    redraw!
    Copen(@a)
enddef
# }}}

# function DebugMode(){{{
export def DebugMode()
    def ExitDebugMode()
        silent! cclose
        ExitMode()
        # unlet ExitModeFunc
    enddef

    def DebugModeInit(): bool
        silent! ExitModeFunc()
        if expand('%') !~# '\v.*\.c(pp)='
            Notify(['不进入debug模式'])
            return false
        endif

        ModeInit()
        ExitModeFunc = ExitDebugMode
        return true
    enddef

    def Copen()
        silent copen 13
        setlocal nonumber norelativenumber nolist
        execute "normal! \<c-w>k"
    enddef

    if DebugModeInit()
        silent! execute 'make -f /home/rongzi/.Lectures/term1/hw/program_design/makefile'
        Copen()
    endif
enddef
# }}}

# function RunMode(){{{
def MakeTimeStamp(): func(bool): float
    var last_run_time = reltimefloat(reltime())
    def TimeStampInner(mkstamp: bool = true): float
        const old_time = last_run_time
        const new_time = reltimefloat(reltime())
        if mkstamp ==# true
            last_run_time = new_time
        endif
        return new_time - old_time
    enddef
    return TimeStampInner
enddef
var TimeStamp = MakeTimeStamp()
var term_bufnr: number = -1

export def RunMode()
    def ExitRunMode()
        if bufnr(term_bufnr) !=# -1
            execute 'bd! ' .. term_bufnr
        endif
        ExitMode()
    enddef

    def RunModeInit(): bool
        ExitModeFunc()
        if ['java', 'cpp', 'c', 'python']->index(FileType(expand('%'))) ==# -1
            Notify(['只能运行C/Cpp/Python/Java文件'])
            return false
        endif
        ModeInit()
        ExitModeFunc = ExitRunMode
        return true
    enddef

    if RunModeInit() ==# false
        Notify(['ModeInit失败，不进入RunMode'])
        return
    endif

    var   run_only     = false
    const script_path  = expand('%')
    const filetype     = FileType(script_path)
    const run_cmds     = {'c': 'io -q ', 'cpp': 'io -q ', 'java': 'io -q ', 'python': 'python3 -i '}
    const term_options = {'term_finish': 'open'}
    const time_passby  = TimeStamp(false)

    if time_passby <# 1.5
        run_only = 1
        Notify(['运行过快,据上一次运行只有 ' .. time_passby .. 's'], 'up', float2nr((1.5 - time_passby) * 1000))
    endif

    const cmd = run_cmds[filetype] .. script_path .. (run_only ? ' -r' : '')
    belowright term_bufnr = term_start(cmd, term_options)
    TimeStamp(!run_only)
    execute 'normal! ' .. "\<c-w>k" .. "zz" .. "\<c-w>j"
enddef
# }}}

# aug mode
# au!
# au User GrepModeTrigger  normal! g@iw
# au User DebugModeTrigger call DebugMode()
# au User RunModeTrigger   call RunMode()
# nn <leader>r :doautocmd User RunModeTrigger<CR>
# nn <silent> <leader>r <CMD>call RunMode()<CR>
# nn <silent> <leader>d :doautocmd User DebugModeTrigger<CR>
# nn <silent> <leader>g :let &operatorfunc=funcref("GrepOperator")<CR>:doautocmd User GrepModeTrigger<CR>
# vn <silent> <leader>g <CMD>let &operatorfunc=funcref("GrepOperator")<CR>g@


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
