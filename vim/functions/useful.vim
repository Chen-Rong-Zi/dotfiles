" use fzf to select files quickly
function! SelectFile()
    let tmp = tempname()
    silent execute '!sudo find ~ | fzf -m >'.tmp
    for fname in readfile(tmp)
        if @% == ''
            silent execute 'e '.fname
        else
            silent execute 'vsplit '.fname
        endif
    endfor
    silent execute '!rm '.tmp
    silent execute 'redraw!'
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
    if @% != ''
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
