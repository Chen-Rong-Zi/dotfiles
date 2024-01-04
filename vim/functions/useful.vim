" use fzf to select files quickly
function! SelectFile()
    let tmp = tempname()
"     silent execute '!sudo find ~ | fzf -m >'.tmp
"     another way to use fzf in vim
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

nn <leader><c-f> :call SelectFile()<CR>

" ues another way to show chars when in console
if $DISPLAY == ""
    set notermguicolors
    set fillchars=vert:\|
    set listchars=leadmultispace:\|\ \ \ ,trail:-,precedes:>,extends:<,tab:\ \ 
    color zellner
endif

" unknow
function! ShowLastStatus()
    if @% == '/bin/bash'
        set laststatus=0
    else
        set laststatus=2
    endif
endfunction

" quickly change to the directory the buffer lies in
function! ChangeDirectory()
    execute "cd" expand('%:p:h')
endfunction

" toggle conceal chars
function! ToggleConcealLevel()
    if &conceallevel == 0
        setlocal conceallevel=2
    else
        setlocal conceallevel=0
    endif
endfunction

nnoremap <silent> <C-c><C-y> :call ToggleConcealLevel()<CR>

" switch to another buffer
" <++>TODO
function! SwitchBuffer()
    bnext
    silent execute '!notify-send -i vim another buffer'
    silent execute 'redraw!'
endfunction
" nnoremap <silent> <c-p> :call SwitchBuffer()<CR>
"
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

" wrap the selected text with a:char
function! Wrapper(left, ...)
    let left = a:left
    let right = (a:0 == 1) ? a:1 : left
    if left == right
        if left == "("
            let right = ")"
        elseif left == "["
            let right = "]"
        elseif left == "b"
            let right = ")"
        elseif left == "<"
            let right = ">"
        elseif left == "{"
            let right = "}"
        elseif left == "/*"
            let right = "   */"
        elseif left == "“"
            let right = "”"
        endif
    endif
    let @z = l:left . @z . l:right
    execute ':normal!  "zgPx'
endfunction

vn i "zc <Esc>: call Wrapper("")<left><left>
vn <silent> ( "zc <Esc>: call Wrapper('(',     ')')<CR>
vn <silent> [ "zc <Esc>: call Wrapper('[',     ']')<CR>
vn <silent> { "zc <Esc>: call Wrapper('{',     '}')<CR>
vn <silent> <leader>< "zc <Esc>: call Wrapper('<', '>')<CR>
vn <silent> " "zc <Esc>: call Wrapper('"',    '"')<CR>
vn <silent> ' "zc <Esc>: call Wrapper(''',     ''')<CR>
vn <silent> ` "zc <Esc>: call Wrapper('```\n', '\n```\n')<CR>
