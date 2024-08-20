" grep niho
function! VimGrepOperator(type)
    if a:type ==# 'v'
        execute "normal! `<v`>y"
    elseif a:type ==# 'char'
        execute "normal! `[v`]y"
    else
        return
    endif
    call Print("已复制 " . shellescape(@@), "Error")
endfunction

" nn <leader>g :set operatorfunc=VimGrepOperator<CR>g@
" vn <leader>g :<c-u>call VimGrepOperator(visualmode())<CR>
