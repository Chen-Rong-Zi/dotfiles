" function! AddTableRow(){{{
function! AddTableRow()
    let pos     = getpos('.')
    let columns = max([getline(pos[1]-1)->count('|') - 1, 2])
    let column  = ' <++> |'
    return range(columns)->reduce({old, new -> old . column}, '|')
endfunction
" }}}

" function! ReplacePairs(){{{
function! ReplacePairs()
    function! GetPairs(char)
        " let pairs = &matchpairs->split(',')->map({i, v -> v->split(':')})
        if ['{', '}']->index(a:char) !=# -1
            return ['{', '}']
        elseif ['(', ')']->index(a:char) !=# -1
            return ['(', ')']
        elseif ['[', ']']->index(a:char) !=# -1
            return ['[', ']']
        elseif ['<', '>']->index(a:char) !=# -1
            return ['<', '>']
        else
            return [a:char, a:char]
        endif
    endfunction
    normal %
    let pair1 = getcharpos('.')
    normal %
    let pair2 = getcharpos('.')
    if pair1[1] ># pair2[1] || (pair1[1] ==# pair2[1] && pair1[2] ># pair2[2])
        let temp  = pair1
        let pair1 = pair2
        let pair2 = temp
    endif
    let [pair1_row, pair2_row, pair1_col, pair2_col] = [pair1[1], pair2[1], pair1[2], pair2[2]]
    if pair1 ==# pair2    " 若没有组合对则退出
        return Notify(['未发现组合对'])
    endif

    call Print('请输入一个字符', "Function")
    let char  = getcharstr()
    if pair1_row ==# pair2_row
        let line      = getline(pair1_row)->split('\zs')
        let old_pairs = GetPairs(line[pair1_col-1])
        let [line[pair1_col-1], line[pair2_col-1]] = GetPairs(char)
        call setline(pair1_row, line->join(''))
    else
        let [pair1_line, pair2_line] = [pair1_row, pair2_row]->map({i, v->getline(v)->split('\zs')})
        let [pair1_line[pair1_col-1], pair2_line[pair2_col-1]] = GetPairs(char)
        let old_pairs = GetPairs(pair1_line[pair1_col-1])
        call setline(pair1_row, pair1_line->join(''))
        call setline(pair2_row, pair2_line->join(''))
    endif
    call Notify([old_pairs->join(' ') . '被替换为' . GetPairs(char)->join(' ')], 'down', 1000)
endfunction
nn gr <CMD>call ReplacePairs()<CR>
" }}}

" function! CheckBoxToggle(){{{
function! CheckBoxToggle()
    let [a, row, col, d]  = getcharpos('.')
    let line = getline('.')
    let [left, right] = [stridx(line, '['), stridx(line, ']')]
    if left ==# -1 || right ==# -1 || left >=# right
        return Notify(['没有checkbox'])
    endif
    let has_x = (stridx(line, 'x') < left || stridx(line, 'x') > right)? 'x':''
    call setline(row, line[:left] . has_x . line[right:])
endfunction
" }}}

" function! Notify(){{{
function! Notify(texts, location='down', time=800)
    hi clear Pmenu
    hi Pmenu ctermfg=145
    let width  = winwidth(0)
    let height = winheight(0)
    let shift  = max(a:texts->Map('strcharlen(v:val)'))
    if a:location ==# 'up'
        let line = 1
    elseif a:location ==# 'down'
        let line = height
    endif
    call popup_notification(a:texts, {
        \'col': (width/2 - shift / 2),
        \'line': line,
        \'minwidth': shift,
        \'time': a:time,
        \'borderchars' : ['─', '│', '─', '│', '╭', '╮', '╯', '╰']
        \ })
endfunction
" }}}

" function! Icons(){{{
function! Icons(filename)
    return system('exa --icons=always ' . shellescape(a:filename))->split()[0]
endfunction
" }}}

" function! SelectBuffer(){{{
function! SelectBuffer()
    function! OpenBuffer(id, index) closure
        if a:index ==# -1
            return Notify(['取消跳转'], 'up')
        endif
        silent! execute 'buf ' . names[a:index - 1]->split(' ')[0]
        call Notify(['跳转 ' . names[a:index - 1][:-1]])
    endfunction

    let names = getbufinfo({'buflisted': 1})
              \->filter('v:val["name"][0] !=# "!"')
              \->map('v:val["bufnr"] . ((v:val["bufnr"] >= 10)? " ":"  " ). Icons(v:val["name"]) . "  " . v:val["name"]')
    if len(names) !=# 0
        call popup_menu(names, {'borderchars' : ['─', '│', '─', '│', '╭', '╮', '╯', '╰'], 'callback': funcref('OpenBuffer')})
    else
        call Notify(['没有buffer'])
    endif
    call DeleteBuffer()
endfunction
" }}}
nn <leader>e :call SelectBuffer()<CR>

" function! JoshutoSelectFile(){{{
function! JoshutoSelectFile()
    function! OpenBuffer(file)
        echom a:file
        call Notify(['跳转 ' . a:file])
        if a:file ==# '' || system('[[ -d ' . a:file .  ' ]] && echo 1')
            " silent execute 'Explore ' . a:file
            " 似乎vim不能在pop_window打开的时候使用Explore
        elseif @% == ''
            silent execute 'e ' . a:file
        else
            silent execute 'vsplit ' . a:file
        endif
    endfunction

    function! Rest_work(id, result, filename)
        let content    = readfile(a:filename)
        if len(content) ==# 0
            return Notify(['取消跳转'], 'up')
        endif
        let content = content->map({idx, file->OpenBuffer(file)})
        call system("rm -rf " . a:filename)
    endfunction

    hi clear Pmenu
    hi Pmenu ctermfg=145
    let tmp         = tempname()
    let term_buffer = term_start('/home/rongzi/.config/scripts/joshuto_for_vim.sh ' . tmp, {'hidden': 1, 'term_finish': 'close'})
    let pop_window  = popup_create(term_buffer, {'minwidth': 90, 'minheight': 30, 'border': [1, 1, 1, 1], 'borderchars':['─', '│', '─', '│', '╭', '╮', '╯', '╰'], 'callback': {id, result -> Rest_work(id, result, tmp)}})
endfunction
" }}}
nn <leader><c-j> <CMD>call JoshutoSelectFile()<CR>

" function! SelectFile(){{{
" use fzf to select files quickly
function! SelectFile()
    function! OpenBuffer(file)
        echom a:file
        call Notify(['跳转 ' . a:file])
        if a:file ==# '' || system('[[ -d ' . a:file .  ' ]] && echo 1')
            " silent execute 'Explore ' . a:file
            " 似乎vim不能在pop_window打开的时候使用Explore
        elseif @% == ''
            silent execute 'e ' . a:file
        else
            silent execute 'vsplit ' . a:file
        endif
    endfunction

    function! Rest_work(id, result, filename)
        let content    = readfile(a:filename)
        if len(content) ==# 0
            return Notify(['取消跳转'], 'up')
        endif
        let content = content->map({idx, file->OpenBuffer(file)})
        call system("rm -rf " . a:filename)
    endfunction

    hi clear Pmenu
    hi Pmenu ctermfg=145
    let tmp         = tempname()
    let term_buffer = term_start('/home/rongzi/.config/scripts/fzf_for_vim.sh ' . tmp, {'hidden': 1, 'term_finish': 'close'})
    let pop_window  = popup_create(term_buffer, {'minwidth': 130, 'minheight': 20, 'border': [1, 1, 1, 1], 'borderchars':['─', '│', '─', '│', '╭', '╮', '╯', '╰'], 'callback': {id, result -> Rest_work(id, result, tmp)}})
endfunction
" }}}
nn <leader><c-f> <CMD>call SelectFile()<CR>

" function! DeleteBuffer(){{{
function! DeleteBuffer()
    redir => buf_list
    silent! ls
    redir end
    for buf in buf_list->split('\n')
        let tokens = buf->split(' ')
        if tokens[4] =~# '"!/home/rongzi/.config/scripts/.*'
            silent! execute 'bdelete ' . tokens[0]
        endif
    endfor
endfunction
" }}}

" use another way to show chars when in console{{{
if $DISPLAY == ''
    set notermguicolors
    set fillchars=vert:\|
    set listchars=leadmultispace:\|\ \ \ ,trail:-,precedes:>,extends:<,tab:\ \ 
    color zellner
endif
"}}}

"function! ShowLastStatus() unknow{{{
function! ShowLastStatus()
    if @% =~# '!.*'
        set laststatus=0
    else
        set laststatus=2
    endif
endfunction
"}}}

"function! ChangeDirectory()    quickly change to the directory the buffer lies in{{{

function! ChangeDirectory()
    if expand("%") ==# '' || system("cd " . expand("%")) =~# '.*没有.*' || system("cd " . expand("%")) =~# '.*No such.*'
        return
    endif
    execute "cd" expand('%:p:h')
endfunction

function! ChangeSrc()
    if expand("%") ==# '' || system("cd " . expand("%")) =~# '.*没有.*' || system("cd " . expand("%")) =~# '.*No such.*' || expand('%') ==# 'popup'
        return
    endif
    execute "let $src = " . shellescape(expand('%:p'))
endfunction
"}}}

"function! ToggleConcealLevel()   toggle conceal chars{{{

function! ToggleConcealLevel()
    if &conceallevel == 0
        setlocal conceallevel=2
    else
        setlocal conceallevel=0
    endif
endfunction
"}}}

nnoremap <silent> <C-c><C-y> <CMD>call ToggleConcealLevel()<CR>
"function! SwitchBuffer()  switch to another buffer {{{
" <++>TODO
function! SwitchBuffer()
    bnext
    silent execute '!notify-send -i vim another buffer'
    silent execute 'redraw!'
endfunction
" nnoremap <silent> <c-p> <CMD>call SwitchBuffer()<CR>
"}}}

"function! Fcitx5pinyin(){{{
function! Fcitx5pinyin()
    call system('fcitx5-remote -s 拼音')
endfunction
function! Fcitx5keyboard()
    call system('fcitx5-remote -s keyboard')
endfunction

func Eatchar(pat)
    let c = nr2char(getchar(0))
    return (c =~ a:pat) ? '' : c
endfunc
" iabbrev  if if ()<Left><C-R>=Eatchar('\s')<CR>
"}}}

" useful expample in help doc :h <expr>{{{

let counter = 0
func! ListItem()
  let g:counter += 1
  return g:counter .. '. '
endfunc

func! ListReset()
  let g:counter = 0
  return ''
endfunc

" inoremap <expr> <C-L> ListItem()
" inoremap <expr> <C-R> ListReset()
" iunmap <c-r>
"}}}


" ███████╗████████╗██████╗ ██╗███╗   ██╗ ██████╗
" ██╔════╝╚══██╔══╝██╔══██╗██║████╗  ██║██╔════╝
" ███████╗   ██║   ██████╔╝██║██╔██╗ ██║██║  ███╗
" ╚════██║   ██║   ██╔══██╗██║██║╚██╗██║██║   ██║
" ███████║   ██║   ██║  ██║██║██║ ╚████║╚██████╔╝
" ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝
"String related functions{{{

function! Print(text, ...)
    if a:0 ==# 0
        echom a:text
    elseif a:0 ==# 1
        exe 'echohl ' . a:000[0]
        echom a:text
        echohl None
    endif
endfunction

"function! SearchSelectedText(){{{
function! SearchSelectedText()
    setl hlsearch
    let @/ = '\M' . substitute(@", '\', '\\\\', 'g')
        \->substitute('\$', '\\$', 'g')
        \->substitute('\n', '\\n', 'g')
    call Notify(["模式:" . strpart(@/, 0, winwidth(0) - 30)])
endfunction

function! SearchArgumentText(string)
    setl hlsearch
    let @/ = '\M' . substitute(a:string, '\', '\\\\', 'g')
        \->substitute('\$', '\\$', 'g')
        \->substitute('\n', '\\n', 'g')
    call Notify([ "模式:" . strpart(@/, 0, winwidth(0) - 30)])
endfunction
"}}}

"function! InsertString(string, row, col){{{
function! InsertString(string, row, col)
    " insert a string to (row, col), by default in the current buffer
    let line = getline(a:row)
    let line = line
        \->split('\zs')
        \->insert(a:string, min([a:col - 1, len(line)]))
        \->join('')
        \->setline(a:row)
endfunction
"}}}

"function! MoveCursor(row, col){{{
function! MoveCursor(row, col)
    echom [a:row, a:col]
    call setcursorcharpos(a:row, a:col)
endfunction
"}}}}}}


"  ██████╗ ██████╗ ███████╗██████╗  █████╗ ████████╗ ██████╗ ██████╗
" ██╔═══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗
" ██║   ██║██████╔╝█████╗  ██████╔╝███████║   ██║   ██║   ██║██████╔╝
" ██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗██╔══██║   ██║   ██║   ██║██╔══██╗
" ╚██████╔╝██║     ███████╗██║  ██║██║  ██║   ██║   ╚██████╔╝██║  ██║
"  ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝
" self defined operators {{{
"function! VisualWrapper(left, ...)  wrap the selected text with char{{{
function! VisualWrapper()
    let start_pos = getcharpos("'<")
    let end_pos   = getcharpos("'>")

    echohl Function
    let left  = input("左侧分隔符: ")
    let right = input("右侧分隔符: ")
    echohl none
    let right = (strcharlen(right) ==# 0)? left : right

    call InsertString(right, end_pos[1],   end_pos[2] + 1)
    call InsertString(left,  start_pos[1], start_pos[2])
    call MoveCursor(start_pos[1], start_pos[2])
endfunction

aug VisualWrapper
autocmd!
au vimenter * vn <leader>w y<CMD>call SearchSelectedText()<CR><CMD>call VisualWrapper()<CR>
aug end
"}}}ksdfh;

"function! MakeWrapper(left = "(", right = ")")     {{{
function! s:MakeWrapper(left = "(", right = ")", stop = 1)
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
            call InsertString(a:right, a:line_number, (a:type == 'line')? strcharlen(a:line) + 1 : end_col + 1)
            call InsertString(a:left,  a:line_number, (a:type == 'line')? 1 : start_col)
        endfunction

        if a:type ==# 'char'
            call InsertString(a:right, end_row,   end_col + 1)
            call InsertString(a:left,  start_row, start_col)
        else
            call getline(start_row, end_row)->map('WrapLine(v:val, v:key + start_row)')
        endif

        if a:stop ==# 1
            return MoveCursor(start_row, start_col)
        endif
        " where stop == 2 case
        if a:type ==# 'char'
            call MoveCursor(end_row, end_col + 1 + (start_row ==# end_row))
        elseif a:type ==# 'block'
            call MoveCursor(end_row, end_col + 2)
        elseif a:type ==# 'line'
            call MoveCursor(end_row, 2147483647)
        endif
    endfunction
    return funcref('OperatorWrapper')
endfunction

" = ((¬p ∨ q) ∧ ¬q) (∨) ((¬p ∨ (q)) ∧ r)
aug OperatorWrapper
autocmd!
au VimEnter * no    (  <CMD>let &operatorfunc=<SID>MakeWrapper('(', ')', 2)<CR>g@
au VimEnter * no    {  <CMD>let &operatorfunc=<SID>MakeWrapper('{', '}', 2)<CR>g@
au VimEnter * no    [  <CMD>let &operatorfunc=<SID>MakeWrapper('[', ']', 1)<CR>g@
au VimEnter * no    "  <CMD>let &operatorfunc=<SID>MakeWrapper('"', '"', 1)<CR>g@
au VimEnter * no    '  <CMD>let &operatorfunc=<SID>MakeWrapper("'", "'", 1)<CR>g@

au VimEnter * nno  ((  0<CMD>let &operatorfunc=<SID>MakeWrapper('(', ')', 1)<CR>g@$
au VimEnter * nno  {{  0<CMD>let &operatorfunc=<SID>MakeWrapper('{', '}', 2)<CR>g@$
au VimEnter * nno  [[  0<CMD>let &operatorfunc=<SID>MakeWrapper('[', ']', 1)<CR>g@$
au VimEnter * nno  ""  0<CMD>let &operatorfunc=<SID>MakeWrapper('"', '"', 1)<CR>g@$
au VimEnter * nno  ''  0<CMD>let &operatorfunc=<SID>MakeWrapper("'", "'", 1)<CR>g@$
aug end


"function! SendKeys(type)  {{{
function! SendKeys(type)
    let start_row = getcharpos("'[")[1]
    let end_row   = getcharpos("']")[1]
    let line      = getline(start_row, end_row)->Filter({k, v -> len(v)})->Map({k, v -> system('tmux send-keys -t {next} ' . shellescape(v) . "\r")})
endfunction
"}}}
nno <c-g> <CMD>set operatorfunc=funcref('SendKeys')<CR>g@$
vn  <c-g> <CMD>set operatorfunc=funcref('SendKeys')<CR>g@

" function! CommentToggle()  {{{
function! CommentToggleMaker(comment)
    function! CommentToggle(type) closure
        function! AddOrDelComment(line, comment)
            if a:line ==# []
                return []
            elseif a:line[0] ==# ' '
                return AddOrDelComment(a:line[1:], a:comment)->insert(' ', 0)
            elseif a:line[0] ==# a:comment[0]
                let comment_len = strcharlen(a:comment)
                if a:line[:comment_len - 1]->join('') ==# a:comment
                    let has_space = a:line[comment_len - 1:] !=# [] && a:line[comment_len] ==# ' '
                    return a:line[comment_len + has_space:]
                endif
            endif
            return (a:comment . ' ')->split('\zs')->extend(a:line)
        endfunction

        let [pos, min_number, max_number] = [getcharpos("']"), getcharpos("'[")[1], getcharpos("']")[1]]
        let content = getline(min_number, max_number)
            \->map('split(v:val, ''\zs'')')
            \->map('AddOrDelComment(v:val, a:comment)')
            \->map('setline(v:key + min_number, (v:val)->join(""))')
        " if content !=# []
            " call MoveCursor(pos[1], pos[2])
        " endif
    endfunction
    return funcref('CommentToggle')
endfunction
"}}}}}}}}}


"function! AddSeprator(){{{
function! AddSeprator()
    exe 'normal! $'
    let pos  = getcharpos(".")
    if getline(pos[1])[pos[2] - 1] !=# ' '
        exe "normal! a \e"
    endif
    return ''
endfunction
"}}}

"function! AddSuffix(){{{
function! AddSuffix(char)
    let line = getline('.')
    for index in range(strcharlen(line)-1, 0, -1)
        if line[index] ==# ' '
            let line =  line[:-2]
        else
            break
        endif
    endfor
    if line[-1:-1] ==# a:char
        return Notify(['该位置已有 ' . a:char, ''])
    endif

    call setline('.', line . a:char)
    normal! mS
    redir => message
    silent! marks S
    redir end
    call Notify(['添加分号至', '']->extend(message->split("\n")))
endfunction
"}}}

" nn <buffer> <silent> ; mqA;<Esc>`q

"function! Quick_CD(){{{
function! Quick_CD()
    echohl keyword
    let input = expand(input("要跳转的目录: "))
    echohl None
    let cmd = 'locate  -l 1 ' . shellescape(input)
    let path = system(cmd)->substitute('\n', '', 'g')
    if path ==# ''
        return Print('没找到', 'Error')
    endif

    if system('[[ -d ' . shellescape(path) . ' ]] && echo 1')
        exe "cd " . path
        return Print("当前处在 " . substitute(system('pwd'), '\n', '', 'g'), 'Preproc')
    elseif system('[[ -f ' . path . ' ]] && echo 1')
        let get_file_cmd = system('echo ' . path . ' | awk -F / -v OFS=/ ''{$NF="";print}''')
        exe "cd " . get_file_cmd
        exe "bo vsplit " . path
    endif
    return
endfunction
nn cd <CMD>call Quick_CD()<CR>
"}}}

"  ███╗   ███╗ ██████╗ ██████╗ ███████╗███████╗
"  ████╗ ████║██╔═══██╗██╔══██╗██╔════╝██╔════╝
"  ██╔████╔██║██║   ██║██║  ██║█████╗  ███████╗
"  ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝  ╚════██║
"  ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗███████║
"  ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝
"self defined modes {{{
function! ModeInit()
    call ExitMode()
    " jump to last M mark if there already have M, otherwise set the M mark here
    exe 'normal! mM'
    nn <c-n> :cnext<CR>
    nn <c-p> :cprev<CR>
    return 1
endfunction

function! ExitMode()
    if getcharpos("'M") !=# [0, 0, 0, 0]
        exe 'normal! `Mzz'
        delmarks M
    endif
    silent! only
    " callee save :-)
    nn <c-n> :bnext<CR>
    nn <c-p> :bprev<CR>
    silent! execute 'nunmap q'
    return 1
endfunction

function! s:GrepOperator(type)
    let last_buffer_number = 'None'
    let save_reg           = 'None'
    function! SaveReg() closure
       let save_reg = @@
    endfunction
    function! RestoreReg() closure
       let @@ = save_reg
    endfunction
    function! Copen(text)
        call SearchArgumentText(a:text)
        copen
        redraw!
        setlocal nolist nonu nornu
        exe "normal! \<c-w>k"
    endfunction
    function! Cnext() closure
        if last_buffer_number ==# 'None'
            let last_buffer_number = bufnr()
            " call Notify([$"did not find s:last_buffer_number"])
            silent! cnext
            return
        endif
        let curr_buffer_number = bufnr()
        if curr_buffer_number != last_buffer_number
            silent! exe "bdelete " .  last_buffer_number
            " call Notify(["delete buffer!"])
        endif
        let last_buffer_number = curr_buffer_number
        silent! cnext
    endfunction
    function! Cprev() closure
        if last_buffer_number ==# 'None'
            let last_buffer_number = bufnr()
            " call Notify([$"did not find last_buffer_number"])
            silent! cnext
            return
        endif
        let curr_buffer_number = bufnr()
        if curr_buffer_number != last_buffer_number
            silent! exe "bdelete " .  last_buffer_number
            " call Notify(["delete buffer!"])
        endif
        let last_buffer_number = curr_buffer_number
        silent! cprev
    endfunction
    function! GrepOperatorInit()
        call SaveReg()
        call ModeInit()
        nn <c-n> <CMD>call Cnext()<CR>
        nn <c-p> <CMD>call Cprev()<CR>
    endfunction
    function! ExitOperatorMode()
        silent! cclose
        call RestoreReg()
        call ExitMode()
    endfunction

    " init the mode
    call GrepOperatorInit()
    silent! normal! `[v`]y

    call Notify(["正在查找：" . @@])
    silent! exe  'grep -Rsi ' . shellescape(@@) . " ."
    call Copen(@@)

    " set the exit of the mode
    nn q <CMD>call ExitOperatorMode() <CR>
endfunction
"}}}

"function! DebugMode(){{{
function! DebugMode()
    function! ExitDebugMode()
        silent! cclose
        call ExitMode()
    endfunction

    function! DebugModeInit()
        silent! normal `M
        if !(expand("%") =~# '.*\.c')
            call Notify(["只有C文件可以Debug"])
            return 0
        endif
        return ModeInit()
    endfunction

    function! Copen()
        silent! copen
        setlocal nonumber norelativenumber nolist
        redraw!
    endfunction

    if !DebugModeInit()
        return 0
    endif

    silent! execute 'make -f /home/rongzi/.Lectures/term1/hw/program_design/makefile'
    call Copen()
    nn q <CMD>call ExitDebugMode() <CR>
endfunction
" }}}

"function! RunMode(){{{
function! RunMode()
    " silent! exe 'make -f /home/rongzi/.Lectures/term1/hw/program_design/makefile'
    function! RunModeInit()
        silent! normal! `M
        if !(expand("%") =~# '.*\.c')
            call Print("错误：只有C文件可以make", "Error")
            return 0
        endif
        return ModeInit()
    endfunction

    if !RunModeInit()
        return 0
    endif
    " let result = system('g++ -o $bin ' . expand('%'))
    " if len(getqflist()) ==# 1
    if 1 ># 0
        " this is where no compile error occurrs
        " setl termwinsize=10*0
        " silent! exe 'bo term ' . $bin
        silent! exe 'bo term io -q ' . expand('%')
        " redraw!
    else
        call DebugMode()
    endif

    nn q <CMD>call ExitMode() <CR>
    return 1
endfunction
" }}}
" {{{
au VimEnter * no <leader>g <CMD>set  operatorfunc=<SID>GrepOperator<CR>g@
" au VimEnter * nn <leader>g <CMD>call GrepMode()    <CR>
au VimEnter * nn <leader>d <CMD>call DebugMode() <CR>
au VimEnter * nn <leader>r <CMD>call RunMode()   <CR>
" }}}

" function! FoldColumnToggle(){{{
function! FoldColumnToggle()
    if &foldcolumn
        let &foldcolumn = 0
    else
        let &foldcolumn = 4
    endif
    return Notify(["foldcolumn = " . &foldcolumn])
endfunction

nn <leader>f <CMD>call FoldColumnToggle()<CR>
"}}}

" quickfix-window-function {{{
" 从 v:oldfiles 来建立快速修复列表
" call setqflist([], ' ', {'lines' : v:oldfiles, 'efm' : '%f', 'quickfixtextfunc' : 'QfOldFiles'})
" func QfOldFiles(info)
    " 获取一段快速修复项目范围的相关信息
    " let items = getqflist({'id' : a:info.id, 'items' : 1}).items
    " let l = []
    " for idx in range(a:info.start_idx - 1, a:info.end_idx - 1)
        " 使用简化的文件名
      " call add(l, fnamemodify(bufname(items[idx].bufnr), ':p:.'))
    " endfor
    " return l
" endfunc
" }}}

function! Outter()
    function! s:Inner()
        call Notify(["nihao"])
    endfunction
    call s:Inner()
endfunction
