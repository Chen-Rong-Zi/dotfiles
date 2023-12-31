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
if &term =~'linux'
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
    if &buftype !=# 'terminal' && &buftype !=# 'help' && !empty(&buftype)
        cd %:h
    endif
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
    silent execute '!fcitx5-remote -s pinyin'
    redraw!
endfunction

function! Fcitx5keyboard()
    silent execute '!fcitx5-remote -s keyboard'
    redraw!
endfunction

func Eatchar(pat)
let c = nr2char(getchar(0))
return (c =~ a:pat) ? '' : c
endfunc
" iabbrev  if if ()<Left><C-R>=Eatchar('\s')<CR>
