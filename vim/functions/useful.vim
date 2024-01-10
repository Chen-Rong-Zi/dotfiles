"function! SelectFile(){{{
" use fzf to select files quickly
function! SelectFile()
    let tmp = tempname()
    silent execute '!/home/rongzi/.config/scripts/fzf_for_vim.sh >'.tmp
    for fname in readfile(tmp)
        if @% == ''
            silent execute 'e '.fname
        else
            silent execute 'vsplit '.fname
        endif
    endfor
    silent execute '!rm '.tmp
    silent execute 'redraw!'
    call system("dunstify -I /usr/share/icons/Papirus/48x48/apps/vim.svg fzf done")
endfunction
"}}}
nn <leader><c-f> <CMD>call SelectFile()<CR>

" use another way to show chars when in console{{{
if $DISPLAY == ""
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
    if expand("%") ==# '' || system("cd " . expand("%")) =~# '.*没有.*' || system("cd " . expand("%")) =~# '.*No such.*'
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

inoremap <expr> <C-L> ListItem()
inoremap <expr> <C-R> ListReset()
iunmap <c-r>
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
    let @/ = substitute(@", '\', '\\\\', 'g')
    let @/ = substitute(@/, '\$', '\\$', 'g')
    let @/ = '\M' . substitute(@/, '\n', '\\n', 'g')
    call Print("模式:" . strpart(@/, 0, winwidth(0) - 30), "Function")
endfunction

function! SearchAugmentText(string)
    setl hlsearch
    let @/ = substitute(a:string, '\', '\\\\', 'g')
    let @/ = substitute(@/, '\$', '\\$', 'g')
    let @/ = '\M' . substitute(@/, '\n', '\\n', 'g')
    call Print( "模式:" . strpart(@/, 0, winwidth(0) - 30), "Function")
endfunction
"}}}

"function! InsertString(string, row, col){{{
function! InsertString(string, row, col)
    " insert a string to (row, col), by default in the current buffer
    let line = getline(a:row)
            \ ->split('\zs')
    let line = line->insert(a:string, min([a:col - 1, len(line)]))
            \ ->join('')
    call setline(a:row, line)
endfunction
"}}}

"function! MoveCursor(row, col){{{
function! MoveCursor(row, col)
    execute 'silent ' . a:row
    execute 'silent normal! 0'
    if a:col ># 1
        let c = a:col - 1
"        e"chom "c = " . l:c
        execute 'normal! ' . l:c . 'l'
    endif
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
    let start_pos    = getcharpos("'<")
    let end_pos      = getcharpos("'>")

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
    let s:left  = a:left
    let s:right = a:right
    let s:stop  = a:stop
    function! s:OperatorWrapper(type)
        let start_pos =  getcharpos("'[")
        let end_pos   =  getcharpos("']")
        let start_col =  start_pos[2]
        let end_col   =  end_pos[2]

        if a:type ==# 'char'
            call InsertString(s:right, end_pos[1],   end_col + 1)
            call InsertString(s:left,  start_pos[1], start_col)
        elseif a:type ==# 'line'
            for line_number in range(start_pos[1], end_pos[1])
                let line_lenth = strcharlen(getline(line_number))
                if line_lenth ==# 0
                    continue
                endif
                call InsertString(s:right, line_number, line_lenth + 1)
                call InsertString(s:left,  line_number, 1)
            endfor
        elseif a:type ==# 'block'
            for line_number in range(start_pos[1], end_pos[1])
                if strcharlen(getline(line_number)) ==# 0
                    continue
                endif
                call InsertString(s:right, line_number, end_col + 1)
                call InsertString(s:left,  line_number, start_col)
            endfor
        endif
        if s:stop ==# 1
            call MoveCursor(start_pos[1], start_col)
        elseif s:stop ==# 2
            call MoveCursor(end_pos[1],   end_col + 1 + (start_pos[1] ==# end_pos[1]))
        endif
    endfunction
endfunction
aug OperatorWrapper
autocmd!
au VimEnter * no  (  <cmd>call  <SID>MakeWrapper('(', ')', 2)<CR><CMD>set operatorfunc=<SID>OperatorWrapper<CR>g@
au VimEnter * no  {  <cmd>call  <SID>MakeWrapper('{', '}', 1)<CR><CMD>set operatorfunc=<SID>OperatorWrapper<CR>g@
au VimEnter * no  [  <cmd>call  <SID>MakeWrapper('[', ']', 2)<CR><CMD>set operatorfunc=<SID>OperatorWrapper<CR>g@
au VimEnter * no  "  <cmd>call  <SID>MakeWrapper('"', '"', 2)<CR><CMD>set operatorfunc=<SID>OperatorWrapper<CR>g@
au VimEnter * no  '  <Cmd>call  <SID>MakeWrapper("'", "'", 2)<CR><CMD>set operatorfunc=<SID>OperatorWrapper<CR>g@

au VimEnter * nno (( 0<cmd>call <SID>MakeWrapper('(', ')', 1)<CR><CMD>set operatorfunc=<SID>OperatorWrapper<CR>g@$
au VimEnter * nno {{ 0<cmd>call <SID>MakeWrapper('{', '}', 1)<CR><CMD>set operatorfunc=<SID>OperatorWrapper<CR>g@$
au VimEnter * nno "" 0<cmd>call <SID>MakeWrapper('"', '"', 1)<CR><CMD>set operatorfunc=<SID>OperatorWrapper<CR>g@$
au VimEnter * nno '' 0<Cmd>call <SID>MakeWrapper("'", "'", 1)<CR><CMD>set operatorfunc=<SID>OperatorWrapper<CR>g@$
au BufEnter * nno <buffer> [[ 0<cmd>call MakeWrapper('[', ']', 1)<cr><cmd>set operatorfunc=OperatorWrapper<cr>g@$
aug end
"}}}}}}


"function! AddSeprator(){{{
function! AddSeprator()
    exe 'normal! $'
    let pos  = getcharpos(".")
    let char = getline(pos[1])[pos[2] - 1]
    if char ==# ' '
        return ''
    else
        exe "normal! a \e"
        return ''
endfunction
"}}}

nn <buffer> <silent> ; mqA;<Esc>`q

"function! Quick_CD(){{{
function! Quick_CD()
    echohl keyword
    let input = expand(input("要跳转的目录: "))
    echohl None
    let cmd = 'locate  -l 1 ' . shellescape(input)
    let path = substitute(system(cmd), '\n', '', 'g')
    "echo $"path = {path}"
    if path ==# ''
        return Print('没找到', 'Error')
    endif

    if system('[[ -d ' . shellescape(path) . ' ]] && echo 1')
        exe "cd " . path
        return Print("当前处在 " . substitute(system('pwd'), '\n', '', 'g'), 'Preproc')
    elseif system('[[ -f ' . path . ' ]] && echo 1')
        let get_file_cmd = system('echo '  . path . ' | awk -F / -v OFS=/ ''{$NF="";print}''')
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
    silent! only
    silent! exe 'normal! `Mzz'
    delmarks M
    " callee save :-)
    nn <c-n> :bnext<CR>
    nn <c-p> :bprev<CR>
    return 1
endfunction

function! s:GrepOperator(type)
    function! SaveReg()
       let s:save_reg = @@
    endfunction
    function! RestoreReg()
       let @@ = s:save_reg
    endfunction
    function! Copen(text)
        call SearchAugmentText(a:text)
        copen
        redraw!
        setlocal nolist nonu nornu
        exe "normal! \<c-w>k"
    endfunction
    function! Cnext()
        if !exists("s:last_buffer_number")
            let s:last_buffer_number = bufnr()
"             call Print($"did not find s:last_buffer_number", "Error")
            silent! cnext
            return
        endif
        let curr_buffer_number = bufnr()
        if curr_buffer_number != s:last_buffer_number
            silent! exe "bdelete " .  s:last_buffer_number
"             call Print("delete buffer!", "Error")
        endif
        let s:last_buffer_number = curr_buffer_number
        silent! cnext
    endfunction
    function! Cprev()
        if !exists("s:last_buffer_number")
            let s:last_buffer_number = bufnr()
"             call Print($"did not find s:last_buffer_number", "Error")
            silent! cnext
            return
        endif
        let curr_buffer_number = bufnr()
        if curr_buffer_number != s:last_buffer_number
            silent! exe "bdelete " .  s:last_buffer_number
"             call Print("delete buffer!", "Error")
        endif
        let s:last_buffer_number = curr_buffer_number
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

    call Print("正在查找：" . @@, "Error")
    silent! exe  'grep -Ri ' . shellescape(@@) . " .. 2>/dev/null"
    call Copen(@@)

    " set the exit of the mode
    nn <leader>qq <CMD>call ExitOperatorMode() <CR>
endfunction
"}}}

"function! DebugMode(){{{
function! DebugMode()
    function! ExitCompileMode()
        silent! cclose
        call ExitMode()
    endfunction

    function! DebugModeInit()
        silent! normal `M
        if !(expand("%") =~# '.*\.c')
            call Print("只有C文件可以Debug", "Error")
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

    silent! execute 'make'
    call Copen()
    nn <leader>qq <CMD>call ExitCompileMode() <CR>
endfunction
" }}}

"function! RunMode(){{{
function! RunMode()
    function! Copen()
        silent! copen
        setlocal nonumber norelativenumber nolist
        redraw!
    endfunction

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

    silent! exe 'make'
    "     this is where no compile error occurrs
    if len(getqflist()) ==# 1
        setl termwinsize=10*0
        silent! exe 'bo term ' . $bin
        redraw!
    else
        call DebugMode()
    endif

    nn <leader>qq <CMD>call ExitMode() <CR>
    return 1
endfunction
"}}}
au VimEnter * no <leader>g <CMD>set  operatorfunc=<SID>GrepOperator<CR>g@
" au VimEnter * nn <leader>g <CMD>call GrepMode()    <CR>
au VimEnter * nn <leader>d <CMD>call DebugMode() <CR>
au VimEnter * nn <leader>r <CMD>call RunMode()   <CR>
"}}}}}}

"function! FoldColumnToggle(){{{
function! FoldColumnToggle()
    if &foldcolumn
        let &foldcolumn = 0
    else
        let &foldcolumn = 4
    endif
    return Print("foldcolumn = " . &foldcolumn, "Preproc")
endfunction

nn <leader>f <CMD>call FoldColumnToggle()<CR>
"}}}

"function! CommentToggle()  {{{
function! CommentToggleMaker(comment)
    let s:comment = a:comment
    function! CommentToggle(type)
        let [min_number, max_number] = [getcharpos("'[")[1],    getcharpos("']")[1]]
        let content                  =  getline(min_number, max_number)

        for line_number in range(min_number, max_number)
            let line = content[line_number - min_number]->split('\zs')
            if line ==# []
                continue
            endif
            for index in range(len(line))
                let char = line[index]
                if char ==# ' '
                    continue
                elseif char !=# ' ' && char != s:comment[0]
                    break
                elseif char ==# s:comment[0]
                    call Print("CommentToggle：去除注释", "Function")
                    for _ in range(len(s:comment))
                        if line[index] ==# s:comment[0]
                            call remove(line, index)
                        endif
                    endfor
                    if line[index] ==# ' '
                        call remove(line, index)
                    endif
                    break
                endif
            endfor
            if char !=# ' ' && char !=# s:comment[0]
                call Print("CommentToggle：增加注释", "String")
                let line = (s:comment . ' ')->split('\zs')->extend(line)
            endif
            call setline(line_number, line->join(''))
        endfor
        call MoveCursor(getcharpos("'[")[1], getcharpos("'[")[2])
    endfunction
endfunction

"}}}
"quickfix-window-function {{{
" 从 v:oldfiles 来建立快速修复列表
" call setqflist([], ' ', {'lines' : v:oldfiles, 'efm' : '%f', 'quickfixtextfunc' : 'QfOldFiles'})
" func QfOldFiles(info)
"     获取一段快速修复项目范围的相关信息
"     let items = getqflist({'id' : a:info.id, 'items' : 1}).items
"     let l = []
"     for idx in range(a:info.start_idx - 1, a:info.end_idx - 1)
"         使用简化的文件名
"       call add(l, fnamemodify(bufname(items[idx].bufnr), ':p:.'))
"     endfor
"     return l
" endfunc
" }}}
