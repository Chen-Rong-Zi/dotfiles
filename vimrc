"                ███╗   ███╗██╗   ██╗██╗   ██╗██╗███╗   ███╗██████╗  ██████╗
"                ████╗ ████║╚██╗ ██╔╝██║   ██║██║████╗ ████║██╔══██╗██╔════╝
"                ██╔████╔██║ ╚████╔╝ ██║   ██║██║██╔████╔██║██████╔╝██║
"                ██║╚██╔╝██║  ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║██╔══██╗██║
"                ██║ ╚═╝ ██║   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║██║  ██║╚██████╗
"                ╚═╝     ╚═╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝

let skip_defaults_vim=1
set nocp
set concealcursor=ni
set conceallevel=2
set viminfo-=h

" set smartindent tabline
set cedit=<c-o>
set eventignore+=FocusGained
set viewoptions=options,cursor,curdir,localoptions,
set confirm
set cursorline
set dictionary+=/home/rongzi/.vim/dictionary/methods.txt
set expandtab
set signcolumn=yes
" set fillchars=vert:|
set fillchars=vert:┃
" set fillchars=vert:│
set nolazyredraw
set list
set tags+=~/.cache/vim/tags

set listchars=leadmultispace:│\ \ \ ,trail:-,precedes:>,extends:<,tab:│\ 
set linebreak
set hlsearch
set rnu nu
set scrolloff=7
set expandtab
set shiftwidth=4
set showcmd
set smoothscroll
" set smarttab tablinae
set softtabstop=4
set sessionoptions=blank,buffers,curdir,help,tabpages,winsize,resize,globals
set synmaxcol=512
set autochdir
set tabstop=4
set redrawtime=200
set updatetime=800
set ignorecase
set smartcase
" set path+=
" set include+=/usr/lib/python3.12/site-packages/
set nowrap
set timeoutlen=500
set matchpairs=(:),{:},[:],\":\",':',<:>
set makeprg=io\ -q\ %
" set previewpopup=height:10,width:60
set pumheight=10
" set path+=**
set completeopt=menuone,popup,noinsert,noselect
set completepopup=height:10,width:10,highlight:CompletePopup
" set complete=.,w,t,k,b
set complete=.,w,t,b,kspell


" set shortmess=acOtT
set shortmess=filnxtToOFc

" set timeoutlen=200
" set ttimeout
" set ttimeoutlen=128
set ttyfast
set virtualedit=NONE
set textwidth=256
set helplang=cn
set termwinsize=10*0
set foldcolumn=0
set foldlevel=100
set foldmethod=indent
set tabpagemax=20
set nu ru ai si ts=4 sw=4

" Leader map
let mapleader = ","
if !exists("g:colorscheme")
    set termguicolors
    set encoding=utf-8
    set fileencodings=UTF-8,gbk,usc-bom,latin1
    colorscheme tokyonight
    " colorscheme onedark
    " syntax off
    let g:tokyonight_style   = 'night'
    let g:colorscheme        = 'tokyonight'
    let g:airline_theme      = 'tokyonight'
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#formatter = 'unique_tail'
    let g:autocomplete       = 1
    let g:HaveCompletion     = 1
    let g:pair_range         = &lines
    let g:indent_range       = &lines
    let g:debug_buffer_limit = 1000
    let g:loaded_matchparen  = 0
    let g:grep_buffer_limit  = 200
    let g:fzf_search_path    = expand('~')
    let &t_SI = "\<Esc>[5 q" . "\<Esc>]12;white\x8"
    let &t_SI = "\<Esc>[5 q" . "\<Esc>]12;white\x8"
    let &t_EI = "\<Esc>[2 q" . "\<Esc>]12;gray\x7"
    " let g:comment = "#"

    let g:MATCHPAIRS = [
        \ ['{', '}'],
        \ ['[', ']'],
        \ ['(', ')'],
        \ ["'", "'"],
        \ ['"', '"'],
        \ ['`', '`'] ]
    let g:coqtail_noimap      = 0
endif
        " \ ['<', '>'],
        " \ ['|', '|'],

" vim buffer tab open-tab
"    " <c-[np]> <c-[ey]> <c-t>
"" tmux buffer tab open-tab
"    " <alt-[up,down,left,right]> <alt-[np]> <c-w>t

" ██████╗ ██╗   ██╗███████╗████████╗
" ██╔══██╗██║   ██║██╔════╝╚══██╔══╝
" ██████╔╝██║   ██║███████╗   ██║
" ██╔══██╗██║   ██║╚════██║   ██║
" ██║  ██║╚██████╔╝███████║   ██║
" ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝
" Rust filetype script settings--------<++>------------{{{
aug Rust
autocmd!
" au filetype rust let g:comment = '//'
au BufNewFile *.rs 0r ~/.vim/template/std.rs
au filetype rust let maplocalleader="1"
au filetype rust let &errorformat=' --> %f:%l:%c,' .. &errorformat
au filetype rust call s:util.Notify(['', 'using Rust syntax'], 'up')
au filetype rust ino <buffer> ; <ScriptCmd>call s:util.AddSuffix(';')<CR>
au filetype rust ino <buffer> <F10> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

au filetype rust ino <buffer> { <ScriptCmd>call s:util.BracketIndent()<CR>
"au filetype rust ino <silent> <buffer> { <right>{<CR>}<Esc>O
"au filetype rust ino <buffer> { <esc>A{<CR><++>}<ESC>O
au filetype rust ino <buffer> <leader>c /*    */<esc>4<left>a
au filetype rust ino <silent> <buffer> <c-l> <c-r>=RustGuessExpand()<CR>
au filetype rust ino <silent> <buffer> <expr> <leader><leader> Expand('= 0')
au filetype rust ino <buffer> <leader>d ::
au filetype rust ino <buffer> <leader>sd std::
au filetype rust ino <buffer> : :<space><ScriptCmd>call util.RustTypeCompletion()<CR>
au filetype rust iabbr <buffer> as as<ScriptCmd>call util.RustTypeCompletion()<CR>
au filetype rust iabbr <buffer> -> -><ScriptCmd>call util.RustTypeCompletion()<CR>

" au filetype rust ino <buffer> <leader>f for ( <++> )<CR>{}<left><CR><esc>O<++><esc>2k0f<cf>
" # au filetype rust nn <leader>r :w!<CR>:!cc %<CR><CR>:ter<CR>
au filetype rust nn <buffer> <F10> i0, 1, 2, 3, 4, 5, 6, 7, 8, 9<Esc>
au filetype rust nn <buffer> <F1> :syntax clear \|\| syntax on<CR>
au filetype rust nn <buffer> ;    <ScriptCmd>call s:util.AddSuffix(';')<CR>

" ABBREVIATION
au filetype rust inorea <silent> <buffer> ll \| \| <++><Esc>2F\|a
au filetype rust inorea <silent> <buffer> pu      public
au filetype rust inorea <silent> <buffer> sc      static
au filetype rust inorea <silent> <buffer> pr      private
au filetype rust inorea <silent> <buffer> pt      protected
au filetype rust inorea <silent> <buffer> itn      int
au filetype rust inorea <silent> <buffer> vec     vec![]<left><c-r>=Eatchar('\s')<CR>
au filetype rust inorea <silent> <buffer> vector     Vec
" au filetype rust inorea <silent> <buffer> ao      auto
" au filetype rust inorea <silent> <buffer> var      auto
" au filetype rust inorea <silent> <buffer> val      const
au filetype rust inorea <silent> <buffer> vectro   vector<><left><C-R>=Eatchar('\s')<CR>
au filetype rust inorea <silent> <buffer> retrun   return
au filetype rust inorea <silent> <buffer> retunr   return
au filetype rust inorea <silent> <buffer> reutrn   return
" au filetype rust inorea <silent> <buffer> for      for i in 0..<c-r>=Eatchar('\s')<CR>
" au filetype rust inorea <silent> <silent> <buffer> while  while ( )<left><left>
" au filetype rust inorea <silent> <silent> <buffer> while  while
" au filetype rust inorea <silent> <buffer> self     this-><C-R>=Eatchar('\s')<CR>
au filetype rust inorea <silent> <buffer> #i       # include <><left><C-R>=Eatchar('\s')<CR>
au filetype rust inorea <silent> <buffer> #I       # include <><left><C-R>=Eatchar('\s')<CR>
au filetype rust inorea <silent> <buffer> mm       main()
au filetype rust inorea <silent> <buffer> pp       println!("", <++>);<c-o>F"<C-R>=Eatchar('\s')<CR>
" au filetype rust inorea <silent> <buffer> ss       scanf("",  <++>);<c-o>F"<C-R>=Eatchar('\s')<CR>
au filetype rust inorea <silent> <buffer> kd       %d<C-R>=Eatchar('\s')<CR>
au filetype rust inorea <silent> <buffer> kx       %x<C-R>=Eatchar('\s')<CR>
au filetype rust inorea <silent> <buffer> kX       %X<C-R>=Eatchar('\s')<CR>
au filetype rust inorea <silent> <buffer> kf       %f<C-R>=Eatchar('\s')<CR>
au filetype rust inorea <silent> <buffer> kc       %c<C-R>=Eatchar('\s')<CR>
au filetype rust inorea <silent> <buffer> ks       %s<C-R>=Eatchar('\s')<CR>
au filetype rust inorea <silent> <buffer> ku       %u<C-R>=Eatchar('\s')<CR>
au filetype rust inorea <silent> <buffer> klf      %lf<C-R>=Eatchar('\s')<CR>
au filetype rust inorea <silent> <buffer> kld      %ld<C-R>=Eatchar('\s')<CR>
au filetype rust inorea <silent> <buffer> klld     %lld<C-R>=Eatchar('\s')<CR>
au filetype rust inorea <silent> <buffer> kllf     %llf<C-R>=Eatchar('\s')<CR>
au filetype rust inorea <silent> <buffer> fuck     Are you alright?

"  <tab> and <space> visualised
au filetype rust setl smartindent
au filetype rust let $src=expand('%:p')
" au BufEnter *.c,*.h,*.cpp highlight link Conceal Keyword
aug end

" }}}

"  ██████╗    ██╗ ██████╗██████╗ ██████╗
" ██╔════╝   ██╔╝██╔════╝██╔══██╗██╔══██╗
" ██║       ██╔╝ ██║     ██████╔╝██████╔╝
" ██║      ██╔╝  ██║     ██╔═══╝ ██╔═══╝
" ╚██████╗██╔╝   ╚██████╗██║     ██║
" ╚═════╝╚═╝     ╚═════╝╚═╝     ╚═╝
" C / CPP filetype script settings--------<++>------------{{{
aug C
autocmd!
au BufNewFile *.c 0r ~/.vim/template/std.c
au BufNewFile *.cpp 0r ~/.vim/template/std.cpp
au filetype c,cpp let maplocalleader="1"
" au filetype c,cpp nn <buffer> mm <ScriptCmd>call s:util.CommentToggleMaker('//')<CR>g@$
au filetype c,cpp nn <buffer> gs <Cmd>CocCommand clangd.switchSourceHeader<CR>
" au filetype c,cpp call s:util.Notify(['', 'using C/Cpp syntax'], 'up')
au filetype c,cpp ino <buffer> ; <ScriptCmd>call s:util.AddSuffix(';')<CR>
au filetype c,cpp ino <buffer> <F10> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

au filetype c,cpp ino <buffer> { <ScriptCmd>call s:util.BracketIndent()<CR>
"au filetype c,cpp ino <silent> <buffer> { <right>{<CR>}<Esc>O
"au filetype c,cpp ino <buffer> { <esc>A{<CR><++>}<ESC>O
au filetype c,cpp ino <buffer> <leader>c /*    */<esc>4<left>a
au filetype c,cpp ino <silent> <buffer> <c-l> <c-r>=CppGuessExpand()<CR>
au filetype c,cpp ino <silent> <buffer> <expr> <leader><leader> Expand('= 0')
au filetype c,cpp ino <buffer> <leader>d ::
au filetype c,cpp ino <buffer> <leader>sd std::
au filetype c,cpp ino <buffer> <leader>tmp template <class T> struct<C-R>=Eatchar('\s')<CR>

" au filetype c,cpp ino <buffer> <leader>f for ( <++> )<CR>{}<left><CR><esc>O<++><esc>2k0f<cf>
" # au filetype c,cpp nn <leader>r :w!<CR>:!cc %<CR><CR>:ter<CR>
au filetype c,cpp nn <buffer> <F10> i0, 1, 2, 3, 4, 5, 6, 7, 8, 9<Esc>
au filetype c,cpp nn <buffer> <F1> :syntax clear \|\| syntax on<CR>
" au filetype c,cpp let g:comment = '//'
au filetype c,cpp nn <buffer> ;    <ScriptCmd>call s:util.AddSuffix(';')<CR>

" ABBREVIATION
au filetype   cpp inorea <silent> <buffer> lm   [<++>] (<++>) {return <++>;}<Esc>2F<ca<<C-R>=Eatchar('\s')<CR>
au filetype   cpp inorea <silent> <buffer> lambda   [=] (<++>) {return <++>;}<Esc>2F<ca<<C-R>=Eatchar('\s')<CR>
au filetype   cpp inorea <silent> <buffer> llambda   [=] (<++>) {<CR>return <++>;<CR>}<Esc>2kf<ca<<C-R>=Eatchar('\s')<CR>
au filetype   cpp inorea <silent> <buffer> lamdba   [=] (<++>) {return <++>;}<Esc>2F<ca<<C-R>=Eatchar('\s')<CR>
au filetype   cpp inorea <silent> <buffer> pu      public
au filetype   cpp inorea <silent> <buffer> sc      static
au filetype   cpp inorea <silent> <buffer> pr      private
au filetype   cpp inorea <silent> <buffer> pt      protected
au filetype   cpp inorea <silent> <buffer> itn      int
au filetype c,cpp inorea <silent> <buffer> ao      auto
au filetype c,cpp inorea <silent> <buffer> var      auto
au filetype c,cpp inorea <silent> <buffer> vecotr   vector<><left><C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> vector   vector<><left><C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> vectro   vector<><left><C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> retrun   return
au filetype c,cpp inorea <silent> <buffer> retunr   return
au filetype c,cpp inorea <silent> <buffer> reutrn   return
au filetype c,cpp inorea <silent> <buffer> for      for ( int i = 0; i <<++>; i += 1 )<CR>{}<left><CR><esc>O<++><esc>2k02f<ca>
au filetype c,cpp inorea <silent> <buffer> ffor     for ( auto &it :<++> )<CR>{}<left><CR><esc>O<++><esc>2k0f<ca>
au filetype c,cpp inorea <silent> <silent> <buffer> while  while ( )<left><left>
au filetype c,cpp inorea <silent> <silent> <buffer> if     if ( )<left><left>
au filetype c,cpp inorea <silent> <buffer> self     this-><C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> #i       # include <><left><C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> #I       # include <><left><C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> mm       main(const int arg_number, const char **arg_value)
au filetype c,cpp inorea <silent> <buffer> pp       printf("", <++>);<c-o>F"<C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> ss       scanf("",  <++>);<c-o>F"<C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> kd       %d<C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> kx       %x<C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> kX       %X<C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> kf       %f<C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> kc       %c<C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> ks       %s<C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> ku       %u<C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> klf      %lf<C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> kld      %ld<C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> klld     %lld<C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> kllf     %llf<C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> fuck     Are you alright?

"  <tab> and <space> visualised
au filetype c,cpp setl autoindent
au filetype c,cpp let $src=expand('%:p')
" au BufEnter *.c,*.h,*.cpp highlight link Conceal Keyword
aug end
" }}}

"      ██╗ █████╗ ██╗   ██╗ █████╗ 
"      ██║██╔══██╗██║   ██║██╔══██╗
"      ██║███████║██║   ██║███████║
" ██   ██║██╔══██║╚██╗ ██╔╝██╔══██║
" ╚█████╔╝██║  ██║ ╚████╔╝ ██║  ██║
"  ╚════╝ ╚═╝  ╚═╝  ╚═══╝  ╚═╝  ╚═╝
" java filetype script settings--------<++>------------{{{
aug java
autocmd!
au BufNewFile *.java 0r! sed 's/<++>/%:r/g' ~/.vim/template/std.java
au filetype java setl errorformat=%f:%l:\ %m
au filetype java let maplocalleader="1"
au filetype java call s:util.Notify(['', 'using Java syntax'], 'up')
au filetype java ino <buffer> { <ScriptCmd>call s:util.BracketIndent()<CR>
au filetype java ino <buffer> } {}<left>
au filetype java ino <buffer> <F10> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
au filetype java ino <buffer> ; <ScriptCmd>call s:util.AddSuffix(';')<CR>

" au filetype java ino <buffer> <leader>f for ( <++> )<CR>{}<left><CR><esc>O<++><esc>2k0f<cf>
" # au filetype java nn <leader>r :w!<CR>:!cc %<CR><CR>:ter<CR>
au filetype java nn <buffer> <F10> i0, 1, 2, 3, 4, 5, 6, 7, 8, 9<Esc>
au filetype java nn <buffer> <F1> :syntax clear \|\| syntax on<CR>
" au filetype java let g:comment = '//'
au filetype java nn <buffer> ; <ScriptCmd>call s:util.AddSuffix(';')<CR>
au filetype java nn <buffer> <leader>j <ScriptCmd>call s:util.UpdateToDataBase()<CR>

" ABBREVIATION
au filetype java inorea <silent> <buffer> lambda   (<++>) {return <++>;}<Esc>2F<ca<<C-R>=Eatchar('\s')<CR>
au filetype java inorea <silent> <buffer> lamdba   (<++>) {return <++>;}<Esc>2F<ca<<C-R>=Eatchar('\s')<CR>
au filetype java inorea <silent> <buffer> itn      int
au filetype java inorea <silent> <buffer> fin      final
au filetype java inorea <silent> <buffer> val      const
au filetype java inorea <silent> <buffer> self     this.<c-r>=Eatchar('\s')<CR>
au filetype java inorea <silent> <buffer> retrun   return
au filetype java inorea <silent> <buffer> retunr   return
au filetype java inorea <silent> <buffer> reutrn   return
au filetype java inorea <silent> <buffer> for      for ( int i = 0; i <<++>; i += 1 )<CR>{}<left><CR><esc>O<++><esc>2k02f<ca>
au filetype java inorea <silent> <buffer> ffor     for ( var i : <++> )<CR>{}<left><CR><esc>O<++><esc>2k0f<ca>
au filetype java inorea <silent> <silent> <buffer> while  while ( )<left><left>
au filetype java inorea <silent> <silent> <buffer> if     if ( )<left><left>
au filetype java inorea <silent> <buffer> mm       main(String[] args)
au filetype java inorea <silent> <buffer> pp       System.out.println(<++>);<Esc>F<ca<<C-R>=Eatchar('\s')<CR>
au filetype java inorea <silent> <buffer> pf       System.out.printf("<++>", <++>);<Esc>2F<ca<<C-R>=Eatchar('\s')<CR>
au filetype java inorea <silent> <buffer> sc       static
au filetype java inorea <silent> <buffer> ps       public static
au filetype java inorea <silent> <buffer> pu       public
au filetype java inorea <silent> <buffer> pr       private
au filetype java inorea <silent> <buffer> kd       %d<C-R>=Eatchar('\s')<CR>
au filetype java inorea <silent> <buffer> kx       %x<C-R>=Eatchar('\s')<CR>
au filetype java inorea <silent> <buffer> kX       %X<C-R>=Eatchar('\s')<CR>
au filetype java inorea <silent> <buffer> kf       %f<C-R>=Eatchar('\s')<CR>
au filetype java inorea <silent> <buffer> kc       %c<C-R>=Eatchar('\s')<CR>
au filetype java inorea <silent> <buffer> ks       %s<C-R>=Eatchar('\s')<CR>
au filetype java inorea <silent> <buffer> ku       %u<C-R>=Eatchar('\s')<CR>
au filetype java inorea <silent> <buffer> klf      %lf<C-R>=Eatchar('\s')<CR>
au filetype java inorea <silent> <buffer> kld      %ld<C-R>=Eatchar('\s')<CR>
au filetype java inorea <silent> <buffer> klld     %lld<C-R>=Eatchar('\s')<CR>
au filetype java inorea <silent> <buffer> kllf     %llf<C-R>=Eatchar('\s')<CR>
au filetype java inorea <silent> <buffer> fuck     Are you alright?

"  <tab> and <space> visualised
au filetype java setl cindent
au filetype java let $src=expand('%:p')
au filetype java setl include="/home/rongzi/.vim/dictionary"
au filetype java setl path="/home/rongzi/.vim/dictionary"
au filetype java setl includeexpr='method\.json'
au filetype java setl dictionary+=/home/rongzi/.vim/dictionary/method.json
" au BufEnter *.c,*.h,*.cpp highlight link Conceal Keyword
aug end

" }}}


" ██████╗ ██╗   ██╗████████╗██╗  ██╗ ██████╗ ███╗   ██╗
" ██╔══██╗╚██╗ ██╔╝╚══██╔══╝██║  ██║██╔═══██╗████╗  ██║
" ██████╔╝ ╚████╔╝    ██║   ███████║██║   ██║██╔██╗ ██║
" ██╔═══╝   ╚██╔╝     ██║   ██╔══██║██║   ██║██║╚██╗██║
" ██║        ██║      ██║   ██║  ██║╚██████╔╝██║ ╚████║
" ╚═╝        ╚═╝      ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
" python filetype script settings--------<++>------------{{{
"
aug python
autocmd!
" au BufNewFile *.py i#date:<C-r>=strftime("20%y/%m/%d/%A")
" au BufNewFile *.py i#coding=UTF-8<Enter>
" au BufNewFile *.py i#time:<C-r>=strftime("%H:%m")
au BufNewFile *.py 0r ~/.vim/template/std.py

au filetype python compiler pylint
au filetype python setl makeprg=pylint\ --reports=n\ --msg-template=\"{path}:{line}:\ {msg_id}\ {symbol},\ {obj}\ 错误：{msg}\"\ %:p
au filetype python setl errorformat=%f:%l:\ %m
au filetype python setl cindent
au filetype python call s:util.Notify(['', 'using python syntax'], 'up')
au filetype python ino <buffer> ; <ScriptCmd>call s:util.AddSuffix(':')<CR>
au filetype python ino <buffer> # #<space><left><right>
au filetype python ino <silent> <buffer> <leader>d <c-r>=Expand('::')<CR>
" au filetype python ino <buffer> , ,<space><left><right>


" au filetype python nn <buffer> mm <ScriptCmd>call s:util.CommentToggleMaker('#')<CR>g@$
au filetype python nn <buffer> <F1> :syntax clear \|\| syntax on<CR>
au filetype python nn <buffer> ; <ScriptCmd>call s:util.AddSuffix(':')<CR>
au filetype python nn <buffer> <leader>test :botright terminal python_test<CR>
" Comment the line
" au filetype python let g:comment = '#'
" au filetype python ono <buffer> ( :<C-u>normal!t)lvi(<cr>

au filetype python ino <silent> <buffer> <c-l> <c-r>=GuessExand()<CR>
au filetype python ino <buffer> : :<space>
" au filetype python ia <buffer> if if:<left>
" au filetype python ia <buffer> for for:<left>
" au filetype python ia <buffer> else else:<left>
au filetype python inorea <silent> <buffer> pp print(f"{}")<c-o>F}<C-R>=Eatchar('\s')<CR>
au filetype python inorea <buffer> while  while:<left>
au filetype python inorea <buffer> def    def:<left>
au filetype python inorea <buffer> class  class:<left>
au filetype python inorea <buffer> lambda lambda:<left>
au filetype python inorea <buffer> lamdba lambda:<left>
au filetype python inorea <buffer> ret    return
au filetype python inorea <buffer> @@     1398881912@qq.com
au filetype python inorea <buffer> pirnt  print

" au BufEnter *.py highlight link Conceal Keyword
aug end
" }}}
"

" ██╗   ██╗██╗███╗   ███╗
" ██║   ██║██║████╗ ████║
" ██║   ██║██║██╔████╔██║
" ╚██╗ ██╔╝██║██║╚██╔╝██║
"  ╚████╔╝ ██║██║ ╚═╝ ██║
"   ╚═══╝  ╚═╝╚═╝     ╚═╝
"vim filetype script settings--------------<++>------------------{{{
aug vim
autocmd!
au filetype vim inorea <silent> <buffer> val const
au filetype vim inorea <silent> <buffer> == ==#
au filetype vim inorea <silent> <buffer> != !=#
au filetype vim inorea <silent> <buffer> =~ =~#
au filetype vim inorea <silent> <buffer> !~ !~#
au filetype vim inorea <silent> <buffer> >= >=#
au filetype vim inorea <silent> <buffer> <= <=#
au filetype vim inorea <silent> <buffer> lambda (<++> ) => <++><Esc>2F<ca<
au filetype vim inorea <silent> <buffer> lamdba (<++> ) => <++><Esc>2F<ca<
au filetype vim call s:util.Notify(['', 'using vim syntax'], 'up')
au filetype vim nn <silent> <buffer> <leader>c <c-v>0I" <esc>
au filetype vim vn <silent> <buffer> <leader>c <C-v>0I" <esc>
au filetype vim ino <buffer> { <ScriptCmd>call s:util.BracketIndent()<CR>
au filetype vim ino <silent> <buffer> <c-l> <c-r>=GuessExand()<CR>
" au filetype vim let  maplocalleader    = "1"
au filetype vim setl foldmethod=marker
" au filetype vim if getline(1) =~# '.*vim9script.*'
                        " \| let g:comment = "#"
                        " \| echom "vim9 comment"
                        " \| else
                        " \| let g:comment = '"'
                        " \| echom "vimscript comment"
                        " \| endif
aug end
"}}}
"

" ████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ██╗
" ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗██║
"    ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║██║
"    ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║██║
"    ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║███████╗
"    ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝
"terminal buffer script settings--------------<++>------------------{{{
aug terminal
autocmd!
au terminalOpen * tno <buffer> <c-[><c-[> <c-w>N
au terminalOpen * tno <buffer> <leader>k  <c-w>k
au terminalOpen * set nowrap
" au TerminalOpen * nn q <ScriptCmd>:call s:util.DeleteTerminal() \| unmap q<CR>
au TerminalOpen * if &buftype ==# 'terminal'
                \ | setlocal nolist
                \ | setlocal nornu
                \ | endif
" au TerminalOpen * let &number = 0
" au TerminalOpen * let &relativenumber = 0
" au TerminalOpen * setlocal nolist
" au TerminalOpen * :vertical resize -7
aug end
" }}}

" ██████╗ ██╗     ██╗   ██╗ ██████╗       ██╗███╗   ██╗
" ██╔══██╗██║     ██║   ██║██╔════╝       ██║████╗  ██║
" ██████╔╝██║     ██║   ██║██║  ███╗█████╗██║██╔██╗ ██║
" ██╔═══╝ ██║     ██║   ██║██║   ██║╚════╝██║██║╚██╗██║
" ██║     ███████╗╚██████╔╝╚██████╔╝      ██║██║ ╚████║
" ╚═╝     ╚══════╝ ╚═════╝  ╚═════╝       ╚═╝╚═╝  ╚═══╝
" plug-in settings---------<++>-----------{{{
" NERDTree
" noremap <leader>t :NERDTreeToggle<CR>

" easymotion
nn <c-f> <plug>(easymotion-prefix)s


call plug#begin()
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'
" Make sure you use single quotes
Plug 'vim-airline/vim-airline-themes', { 'frozen': 1 }
Plug 'vim-airline/vim-airline',        { 'frozen': 1, 'for': ['python', 'rust', 'c', 'cpp', 'java'], 'on': 'AirlineRefresh' }
" if &filetype !=# 'man'
    " au SourcePost * ++once AirlineRefresh
" endif

Plug 'junegunn/fzf',     { 'do': { ->    fzf#install() } }
Plug 'junegunn/fzf.vim', { }

Plug 'Chen-Rong-Zi/gmotion.vim', { 'do': { -> popup_notification(['Gmotion Installed'], {'time': 1000})}}
" let g:gmotion_pair = g:MATCHPAIRS

Plug 'Chen-Rong-Zi/fcitx.vim', {'on': ['FcitxStart', 'FcitxStop']}

Plug 'yianwillis/vimcdoc'

Plug 'neoclide/coc.nvim', { 'frozen': 1, 'branch': 'release', 'for': ['c', 'python', 'cpp', 'java', 'rust'] }

Plug 'easymotion/vim-easymotion', {'on': '<plug>(easymotion-prefix)s', 'frozen': 1}

Plug 'puremourning/vimspector', {}
Plug 'whonore/Coqtail'
let g:vimspector_enable_mappings = 'HUMAN'

" " If you don't have nodejs and yarn
" use pre build, add 'vim-plug' to the filetype list so vim-plug can update this plugin
" see: https://github.com/iamcco/markdown-preview.nvim/issues/50
" Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
" If you have nodejs
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install', 'for': 'markdown' }
" Plug 'pycqa/pylint'
" Plug 'vim-scripts/pylint.vim'
call plug#end()
" }}}


" ███╗   ██╗ ██████╗ ██████╗ ███╗   ███╗ █████╗ ██╗
" ████╗  ██║██╔═══██╗██╔══██╗████╗ ████║██╔══██╗██║
" ██╔██╗ ██║██║   ██║██████╔╝██╔████╔██║███████║██║
" ██║╚██╗██║██║   ██║██╔══██╗██║╚██╔╝██║██╔══██║██║
" ██║ ╚████║╚██████╔╝██║  ██║██║ ╚═╝ ██║██║  ██║███████╗
" ╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝
" Normal settings setted when entering vim--------------<++>------------------{{{
aug normal
autocmd!

" au TextChangedI * call s:util.Complete()
autocmd BufRead,BufNewFile *.gms set filetype=gms
au CmdwinEnter * nn <buffer> <c-m> <CR>
au VimEnter * nn  <c-m> <c-]>
au VimEnter * nn  <leader><tab> <CMD>let g:autocomplete = !g:autocomplete \| echom g:autocomplete<CR>
au VimEnter * ino <leader><tab> <CMD>let g:autocomplete = !g:autocomplete \| echom g:autocomplete<CR>
au VimEnter * ino } {}<left>
au VimEnter * nn  <leader>m m
au VimEnter * nn  <leader>tt <CMD>botright term++close<CR>
au VimEnter * nn  \ "
au VimEnter * vn  \ "
au VimEnter * nn  <s-h> 2zh
au VimEnter * nn  <s-l> 2zl

" INSERT mode
" au DirChanged * call s:util.Notify(['当前位于' . expand('%:~')], 'up')


" au VimEnter * filetype on
" au VimEnter * syntax   on
" au BufEnter * match Comment / /
au QuickFixCmdpre * setl nowrap
au filetype qf nn <buffer> <c-m> <CMD>execute string(line('.')) .. 'cc'<CR>
au filetype qf wincmd J
" au QuickFixCmdpre * setl numberwidth=2
" au QuickFixCmdpre * setl nonumber
" au QuickFixCmdpre * setl nornu
" au QuickFixCmdpost * setl filetype=cpp
" au VimEnter * nn <silent> <CR> :call ChangeDirectory()<CR>

" swich to the head or the end
au VimEnter * nn  Q "
au VimEnter * nn  /    :set incsearch hlsearch<CR>/\v
au VimEnter * nn  <leader>se <ScriptCmd>call s:util.MakeSession()<CR>
au VimEnter * nn  <leader>sc <ScriptCmd>call s:util.RecoverSession()<CR>
au VimEnter * nn  <leader><space> q:
au VimEnter * nn  <leader>o <CMD>!xdg-open % &<CR>
au VimEnter * nn  <c-h>      ^
au VimEnter * nn  <c-l>      g_
au VimEnter * nn  <c-j>      ;
au VimEnter * nn  <c-k>      zz
" au VimEnter * nn  <silent>   <c-p>       :bnext<CR>
" au VimEnter * nn  <silent>   <c-n>       :bprev<CR>
au VimEnter * nn  <silent>   <c-b>       :bdelete<CR>
au VimEnter * nn  <silent>   <c-e>       :-tabnext<CR>
au VimEnter * nn  <silent>   <c-y>       :+tabnext<CR>
au VimEnter * nn  <silent>   <c-t>       :tabnew<CR>
au VimEnter * nn  <s-j>      <NOP>
au VimEnter * nn  <s-j><s-j> <s-j>
au VimEnter * nn  <s-k>      <Nop>
au VimEnter * nn  Y          yg_
au VimEnter * nn  X          i<CR><Esc>l
au VimEnter * nn  gU         g~
au VimEnter * nn  U          gU

" fold method
au VimEnter * nn <nowait> s  c
au VimEnter * nn ff zA
au Vimenter * nn fk zM
au VimEnter * nn fj zR

" edit $myvimrc
au VimEnter * nn <leader>v :vsplit $MYVIMRC<CR>
au VimEnter * nn <leader>sv :w<CR>:source $MYVIMRC<CR>

" screen create
au VimEnter * nn <leader>sh :set splitright<CR>:vsplit<CR>
au VimEnter * nn <leader>sl :set nosplitright<CR>:vsplit<CR>
au VimEnter * nn <leader>sk :set splitbelow<CR>:split<CR>
au VimEnter * nn <leader>sj :set nosplitbelow<CR>:split<CR>

" screen switch
au VimEnter * nn <leader>k <c-w>K
au VimEnter * nn <leader>j <c-w>J
au VimEnter * nn <leader>h <c-w>H
au VimEnter * nn <leader>l <c-w>L

" screen size
au VimEnter * nn _ :resize   -10<CR>
au VimEnter * nn + :resize   +10<CR>
au VimEnter * nn - :vertical resize -10<CR>
au VimEnter * nn = :vertical resize +10<CR>

" cd to other directory quickly
" au VimEnter * nn <leader>jh :cd ~<CR>
" au VimEnter * nn <leader>jd :cd ~/Downloads<CR>
" au VimEnter * nn <leader>jc :cd ~/.config<CR>
" au VimEnter * nn <leader>jl :cd ~/.Lectures<CR>

"cmap 1 !
au VimEnter * nn w    <c-w>
au VimEnter * nn <BS> :set   hlsearch! incsearch! \| set hlsearch?<CR>

" terminal
" au VimEnter * nn <leader>r :horizontal bo terminal++close bash -rcfile ~/.my_bashrc<CR>
" au VimEnter * nn <leader>r :horizontal bo terminal++close<CR>
" au VimEnter * nn <leader>t :vertical terminal++close<CR>
au VimEnter * nn <leader>i :horizontal bo terminal++close python3 -q <CR>

" save the file in the buffer
" au VimEnter * nn S :w<CR>
au VimEnter * nn S     :s/
au VimEnter * nn <C-s> :w<CR>
au VimEnter * nn g<C-s> <CMD>:silent! w !sudo tee % >/dev/null<CR>

au VimEnter * nn  <F2> :put=system('sed      \"s/\(.*\)/{\1}/g\" <(seq -s \", \" 0 10)')<left><left><left>
au VimEnter * ino <F2> <Esc>:put=system('sed \"s/\(.*\)/{\1}/g\" <(seq -s \", \" 0 10)')<left><left><left>

au VimEnter * ino <silent> <leader>el  <c-r>=Expand('<=')<cr>
au VimEnter * ino <silent> <leader>eg  <c-r>=Expand('>=')<cr>
au VimEnter * ino <silent> <leader>en  <c-r>=Expand('!=')<cr>
au VimEnter * ino <silent> <leader>ee  <c-r>=Expand('==')<cr>
au VimEnter * ino kyi  !
au VimEnter * ino ker  @
au VimEnter * ino ksj  #
au VimEnter * ino ksi  $
" au VimEnter * ino <silent> kwu  <c-r>=Expand('%')<cr>
au VimEnter * ino kl  ^
au VimEnter * ino kq  &
au VimEnter * ino kw  %
au VimEnter * ino kr  $
au VimEnter * ino <silent> kba  <c-r>=Expand('*')<cr>
au VimEnter * ino <silent> jx  <c-r>=Expand('+')<cr>
au VimEnter * ino <silent> jm  <c-r>=Expand('-')<cr>
au VimEnter * ino <silent> kui  <c-r>=Expand('+')<cr>
au VimEnter * ino ka  ()<left>
au VimEnter * ino kb {}<left>
au VimEnter * ino kc []<left>
au VimEnter * ino } {}<left>
au VimEnter * ino (  ()<left>
au VimEnter * ino <c-o>  ()<left>
au VimEnter * ino [  []<left>
au VimEnter * ino {  {}<left>
au VimEnter * ino '  ''<left>
au VimEnter * ino "  ""<left>

" surround the word in the insert mode
au VimEnter * ino <leader>' <Esc>viWA'<esc>Bi'<esc>ela
au VimEnter * ino <leader>" <Esc>viWA"<esc>Bi"<esc>ela
au VimEnter * ino <leader>( <Esc>viWA)<esc>Bi(<esc>ela
au VimEnter * ino <leader>[ <Esc>viWA]<esc>Bi[<esc>ela
au VimEnter * ino <leader>{ <Esc>viWA}<esc>Bi{<esc>ela
au VimEnter * ino <leader>< <Esc>viWA><esc>Bi<<esc>ela

" shortcuts
au VimEnter * ino jk    <esc>
" au VimEnter * ino 经  <esc>       " 使中文下可以使用<jk>退出插入模式
au VimEnter * ino <c-f> <right>
au VimEnter * ino <c-b> <left>
au VimEnter * ino <c-a> <Esc>I
au VimEnter * ino <c-e> <Esc>g_a
au VimEnter * ino <c-h> <BS>
au VimEnter * ino <c-s> <Esc>:w<CR>

au VimEnter * cno <c-r> <c-o>
au VimEnter * cno <c-b> <left>
au VimEnter * cno <c-f> <right>
au VimEnter * cno <c-a> <c-b>

" Transform the word to UPPER-CASE
au VimEnter * ino <BS>     <Nop>
au VimEnter * ino <silent> <c-u>    <esc>viwUviwA
au VimEnter * ino <silent> <c-j>    <ScriptCmd>:call s:util.CR()<CR>
au VimEnter * ino <c-c>    <Esc>
au VimEnter * ino <c-v>    <Esc>viw
au VimEnter * ono <c-l>      g_
au VimEnter * ono <c-h>      ^
" Turn the ; into <CR>
" au VimEnter * cno ; <CR>

" au VimEnter * nn  ; <CR>
" au VimEnter * in ; <Esc>o

" spell check
au VimEnter * nn  <silent> <nowait> cs :setl  spell!<CR>
" au VimEnter * ino <c-x> <Cmd>set spell<CR><c-x>s

" shortcuts switched
au VimEnter * nn  <space> :

" Anchor Point
au VimEnter * ino <leader>f  <esc>/<++><CR>ca<
au VimEnter * nn  <leader>f  /<++><CR>
au VimEnter * nn  <leader>ss :%s/

au VimEnter * vn \|    :!
au VimEnter * vn s     :s/
au VimEnter * vn <c-h> ^
au VimEnter * vn <c-l> g_
" au VimEnter * vn *     y<ScriptCMD>call s:util.SearchSelectedText() \| %s///gn<CR>
au VimEnter * nn v     <ScriptCMD>call s:util.HLSearch()<CR>v
au VimEnter * vn v     <Esc>

au VimEnter * inorea 123 {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
" Comment the line in visual mode
" vn " <c-v>0I" <esc>
au VimEnter * vn #    <c-v>0I#<space><esc>
" au VimEnter * vn /    <C-v>0I//<space><esc>
au VimEnter * vn ;    <C-v>0I;<esc>
au VimEnter * vn <CR> !copy<CR>
au VimEnter * nn *    *N:set hlsearch<CR>
" return to the file .vimrc
au VimEnter * nn <leader>V :e $MYVIMRC<CR>

" return to the current directory
" au VimEnter * nn <leader>e :e .<CR>

" use python3
au VimEnter * vn rp !python3<CR>

"In case that keyborad is sensitive
au VimEnter * vn <s-k>      <Nop>
au VimEnter * vn <s-j><s-j> <s-j>
au VimEnter * vn <s-j>      <Nop>
au VimEnter * vn <c-j>      ;
au VimEnter * vn n          :silent! !~/.config/scripts/align<CR>
au VimEnter * ++once call TermIsLinux()
au VimEnter * ++once call ArgNumberZero()

" ABBREVIATION
au VimEnter * cnorea @u [^\x00-\x7f]+<C-R>=Eatchar('\s')<CR>

function! TermIsLinux()
    if $TERM ==# 'linux'
        if $DISPLAY == ''
            set notermguicolors
            set fillchars=vert:\|
        endif
        set listchars=leadmultispace:\|\ \ \ ,trail:-,precedes:>,extends:<,tab:\ \ 
        color zellner
        set lazyredraw
    endif
endfunction

function! ArgNumberZero()
    " if argc() ==# 0 && &buftype ==# '' && &modified ==# ''
        " let choice = confirm('恢复之前的会话？', "&Yes\n&No\n", 2)
        " if choice ==# 1
            " call s:util.RecoverSession()
        " endif
    " endif
endfunction

aug END
" }}}


"asm filetype script settings--------<++>------------{{{
aug asm
autocmd!
au filetype asm set foldlevel=all
au filetype asm set scrolloff=15
au filetype asm set noexpandtab
au filetype asm set shiftwidth=8
au filetype asm set softtabstop=8
au filetype asm set autoindent
au filetype asm set listchars=leadmultispace:⏐\ \ \ ,trail:-,precedes:>,extends:<,tab:\ \
au filetype asm vn  <buffer> <leader>m <C-v>0I; <esc>
aug end
" }}}


" ███╗   ███╗ █████╗ ███╗   ██╗██████╗  ██████╗  ██████╗
" ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔═══██╗██╔════╝
" ██╔████╔██║███████║██╔██╗ ██║██║  ██║██║   ██║██║
" ██║╚██╔╝██║██╔══██║██║╚██╗██║██║  ██║██║   ██║██║
" ██║ ╚═╝ ██║██║  ██║██║ ╚████║██████╔╝╚██████╔╝╚██████╗
" ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝  ╚═════╝
"man doc settings--------<++>------------{{{
aug man
autocmd!
" au filetype man only
au filetype man set nolist
au filetype man set confirm
au filetype man set foldlevel=10
au filetype man set laststatus=0
au filetype man set scrolloff=15
au filetype man nn  <buffer> d <c-d>
au filetype man nn  <buffer> u <c-u>
au filetype man nn  <buffer> q :q!<CR>
aug end
" }}}


" ██╗  ██╗███████╗██╗     ██████╗ ██████╗  ██████╗  ██████╗
" ██║  ██║██╔════╝██║     ██╔══██╗██╔══██╗██╔═══██╗██╔════╝
" ███████║█████╗  ██║     ██████╔╝██║  ██║██║   ██║██║
" ██╔══██║██╔══╝  ██║     ██╔═══╝ ██║  ██║██║   ██║██║
" ██║  ██║███████╗███████╗██║     ██████╔╝╚██████╔╝╚██████╗
" ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═════╝  ╚═════╝  ╚═════╝
"help doc settings--------<++>------------{{{
aug help
autocmd!
" au filetype man only
au filetype help setl nolist
au filetype help setl confirm
au filetype help setl scrolloff=17
aug end
" }}}


" ███╗   ███╗ █████╗ ██████╗ ██╗  ██╗██████╗  ██████╗ ██╗    ██╗███╗   ██╗
" ████╗ ████║██╔══██╗██╔══██╗██║ ██╔╝██╔══██╗██╔═══██╗██║    ██║████╗  ██║
" ██╔████╔██║███████║██████╔╝█████╔╝ ██║  ██║██║   ██║██║ █╗ ██║██╔██╗ ██║
" ██║╚██╔╝██║██╔══██║██╔══██╗██╔═██╗ ██║  ██║██║   ██║██║███╗██║██║╚██╗██║
" ██║ ╚═╝ ██║██║  ██║██║  ██║██║  ██╗██████╔╝╚██████╔╝╚███╔███╔╝██║ ╚████║
" ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝
"markdown scripts settings--------<++>------------{{{
aug markdown
autocmd!
" au filetype man only
au filetype markdown nn  <buffer> <leader>op <CMD>term ++close bash -c "xdg-open %  2>/dev/null"<CR>
au filetype markdown nn  <buffer> <leader>t <ScriptCmd>call s:util.MarkDownTable()<CR>
" au filetype markdown ino <buffer> <leader>* ******<left><left><left>
" au filetype markdown ino <buffer> g* ****<left><left>
" au filetype markdown ino <buffer> * **<left>
" au filetype markdown ino <buffer> ’ ``<left>
" au filetype markdown ino <buffer> ‘ ``<left>
" au filetype markdown ino <buffer> ' ``<left>
" au filetype markdown ino <buffer> !  ¬
" au filetype markdown ino <buffer> F  ⊥
" au filetype markdown ino <buffer> /  ·
" au filetype markdown ino <buffer> jn ∩
" au filetype markdown ino <buffer> bk ∪
" au filetype markdown ino <buffer> sum ∑
" au filetype markdown ino <buffer> pro ∏
" au filetype markdown ino <buffer> any ∃
" au filetype markdown ino <buffer> all ∀
" au filetype markdown ino <buffer> in  ∈
" au filetype markdown ino <buffer> nin ∉
" au filetype markdown ino <buffer> ziji ⊆
" au filetype markdown ino <buffer> yiho ⊕ 
" au filetype markdown ino <buffer> fuhe ∘
" au filetype markdown ino <buffer> jx ＋
" au filetype markdown ino <buffer> ～ ~~~~<left><left>
" au filetype markdown ino <silent> <buffer> <c-l> <c-r>=Expand('\|')<CR>
" au filetype markdown nn  <buffer> <leader>t <ScriptCmd>put = s:util.AddTableRow()<CR><Esc>^/<++><CR>cw
" au filetype markdown nn  <buffer> <leader><space> <ScriptCMD>call s:util.CheckBoxToggle()<CR>
" au filetype markdown nn  <buffer> <leader>c <ScriptCmd>let &operatorfunc=s:util.IntoLatex<CR>g@l
" au filetype markdown vn  <buffer> <leader>c <ScriptCmd>let &operatorfunc=s:util.IntoLatex<CR>g@
" au filetype markdown abbrev <buffer> void ∅
" au filetype markdown abbrev <buffer> <>  ↔
" au filetype markdown abbrev <buffer> ->  →
" au filetype markdown abbrev <buffer> <-  ←
" au filetype markdown abbrev <buffer> ===  ≡
" au filetype markdown abbrev <buffer> or  ∨
" au filetype markdown abbrev <buffer> and ∧
aug end
" }}}


" ██████╗  █████╗ ███████╗██╗  ██╗
" ██╔══██╗██╔══██╗██╔════╝██║  ██║
" ██████╔╝███████║███████╗███████║
" ██╔══██╗██╔══██║╚════██║██╔══██║
" ██████╔╝██║  ██║███████║██║  ██║
" ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
"bash scripts settings--------<++>------------{{{
aug bash
autocmd!
" au filetype man only
au filetype bash,sh inorea <silent> <buffer> if  if [[<++> ]];then<CR>fi<Esc>?<++><CR>cw
au filetype bash,sh inorea <silent> <buffer> for for<++> in <++>;do<CR>done<Esc>0kf<cw
" Comment the line
" au BufEnter *.sh,*.bash let g:comment='#'
au BufWinEnter *.sh,*.bash setl makeprg=shellcheck\ %
au BufWinEnter *.sh,*.bash let &errorformat='In %f line %l:,' .. &errorformat
aug end
" }}}


" ███████╗ ██████╗ ██╗     ██╗████████╗███████╗
" ██╔════╝██╔═══██╗██║     ██║╚══██╔══╝██╔════╝
" ███████╗██║   ██║██║     ██║   ██║   █████╗
" ╚════██║██║▄▄ ██║██║     ██║   ██║   ██╔══╝
" ███████║╚██████╔╝███████╗██║   ██║   ███████╗
" ╚══════╝ ╚══▀▀═╝ ╚══════╝╚═╝   ╚═╝   ╚══════╝
"sql filetype script settings--------<++>------------{{{
aug sql
autocmd!
au  filetype sql inorea <buffer> select     SELECT
au  filetype sql inorea <buffer> as         AS
au  filetype sql inorea <buffer> create     CREATE
au  filetype sql inorea <buffer> table      TABLE
au  filetype sql inorea <buffer> from       FROM
au  filetype sql inorea <buffer> order      ORDER
au  filetype sql inorea <buffer> where      WHERE
au  filetype sql inorea <buffer> by         BY
au  filetype sql inorea <buffer> add        ADD
au  filetype sql inorea <buffer> all        ALL
au  filetype sql inorea <buffer> alter      ALTER
au  filetype sql inorea <buffer> and        AND
au  filetype sql inorea <buffer> as         AS
au  filetype sql inorea <buffer> asc        ASC
au  filetype sql inorea <buffer> between    BETWEEN
au  filetype sql inorea <buffer> by         BY
au  filetype sql inorea <buffer> case       CASE
au  filetype sql inorea <buffer> check      CHECK
au  filetype sql inorea <buffer> column     COLUMN
au  filetype sql inorea <buffer> constraint CONSTRAINT
au  filetype sql inorea <buffer> create     CREATE
au  filetype sql inorea <buffer> database   DATABASE
au  filetype sql inorea <buffer> default    DEFAULT
au  filetype sql inorea <buffer> delete     DELETE
au  filetype sql inorea <buffer> desc       DESC
au  filetype sql inorea <buffer> distinct   DISTINCT
au  filetype sql inorea <buffer> drop       DROP
au  filetype sql inorea <buffer> else       ELSE
au  filetype sql inorea <buffer> end        END
au  filetype sql inorea <buffer> escape     ESCAPE
au  filetype sql inorea <buffer> exists     EXISTS
au  filetype sql inorea <buffer> foreign    FOREIGN
au  filetype sql inorea <buffer> from       FROM
au  filetype sql inorea <buffer> group      GROUP
au  filetype sql inorea <buffer> having     HAVING
au  filetype sql inorea <buffer> in         IN
au  filetype sql inorea <buffer> index      INDEX
au  filetype sql inorea <buffer> inner      INNER
au  filetype sql inorea <buffer> insert     INSERT
au  filetype sql inorea <buffer> into       INTO
au  filetype sql inorea <buffer> is         IS
au  filetype sql inorea <buffer> join       JOIN
au  filetype sql inorea <buffer> key        KEY
au  filetype sql inorea <buffer> left       LEFT
au  filetype sql inorea <buffer> like       LIKE
au  filetype sql inorea <buffer> limit      LIMIT
au  filetype sql inorea <buffer> not        NOT
au  filetype sql inorea <buffer> null       NULL
au  filetype sql inorea <buffer> on         ON
au  filetype sql inorea <buffer> or         OR
au  filetype sql inorea <buffer> order      ORDER
au  filetype sql inorea <buffer> outer      OUTER
au  filetype sql inorea <buffer> primary    PRIMARY
au  filetype sql inorea <buffer> references REFERENCES
au  filetype sql inorea <buffer> right      RIGHT
au  filetype sql inorea <buffer> select     SELECT
au  filetype sql inorea <buffer> set        SET
au  filetype sql inorea <buffer> table      TABLE
au  filetype sql inorea <buffer> then       THEN
au  filetype sql inorea <buffer> to         TO
au  filetype sql inorea <buffer> union      UNION
au  filetype sql inorea <buffer> unique     UNIQUE
au  filetype sql inorea <buffer> update     UPDATE
au  filetype sql inorea <buffer> values     VALUES
au  filetype sql inorea <buffer> view       VIEW
au  filetype sql inorea <buffer> where      WHERE
au  filetype sql inorea <buffer> with       WITH
aug end
" }}}
"

"   ██████╗ ██████╗  ██████╗ 
"  ██╔════╝██╔═══██╗██╔═══██╗
"  ██║     ██║   ██║██║   ██║
"  ██║     ██║   ██║██║▄▄ ██║
"  ╚██████╗╚██████╔╝╚██████╔╝
"   ╚═════╝ ╚═════╝  ╚══▀▀═╝ 
"
aug coq
autocmd!
au  filetype coq nn <buffer> <s-n> <CMD>RocqNext\|RocqJumpToEnd<CR>
au  filetype coq nn <buffer> <s-p> <CMD>RocqUndo\|RocqJumpToEnd<CR>
aug end


" ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗███████╗
" ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝██╔════╝
" ███████╗██║     ██████╔╝██║██████╔╝   ██║   ███████╗
" ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║   ╚════██║
" ███████║╚██████╗██║  ██║██║██║        ██║   ███████║
" ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝   ╚══════╝
" vim filetype script settings--------<++>------------{{{
aug scripts
au!
import autoload "/home/rongzi/.vim/functions/useful.vim" as util
import autoload "/home/rongzi/.vim/functions/mode.vim"   as mode
au vimenter * nn <leader><c-j> <ScriptCmd>keepjumps call s:util.JoshutoSelectFile()<CR>
au VimEnter * nn <leader><c-f> <ScriptCmd>call s:util.FZFfile()<CR>
au VimEnter * nn <leader>b     <ScriptCmd>call s:util.SelectBuffer()<CR>
au VimEnter * nn <leader>e     <CMD>Buffers<CR>
au VimEnter * nn <silent> <C-c><C-y> <ScriptCmd>call s:util.ToggleConcealLevel()<CR>
au vimenter * vn <leader>w     y<ScriptCmd>call s:util.SearchSelectedText()<CR><ScriptCMD>call s:util.VisualWrapper()<CR>

au VimEnter * nn m  <ScriptCmd>call s:util.CommentToggleMaker()<CR>g@
au VimEnter * nn mm <ScriptCmd>call s:util.CommentToggleMaker()<CR>g@$
au VimEnter * vn m  <ScriptCmd>call s:util.CommentToggleMaker()<CR>g@

au vimenter * nn ( <Cmd>call MakeWrapper('(', ')', 2)<CR>g@
au vimenter * nn ) <Cmd>call MakeWrapper('(', ')', 2, 'block')<CR>g@
au vimenter * nn { <Cmd>call MakeWrapper('{', '}', 2)<CR>g@
au vimenter * nn } <Cmd>call MakeWrapper('{', '}', 2, 'block')<CR>g@
au vimenter * nn [ <Cmd>call MakeWrapper('[', ']', 1)<CR>g@
au vimenter * nn ] <Cmd>call MakeWrapper('[', ']', 1)<CR>g@
au vimenter * nn " <Cmd>call MakeWrapper('"', '"', 2)<CR>g@
au vimenter * nn ' <Cmd>call MakeWrapper("'", "'", 2)<CR>g@

au vimenter * nn (( ^<Cmd>call MakeWrapper('(', ')', 2)<CR>g@g_
au vimenter * nn {{ ^<Cmd>call MakeWrapper('{', '}', 2)<CR>g@g_
au vimenter * nn "" ^<Cmd>call MakeWrapper('"', '"', 2)<CR>g@g_
au vimenter * nn '' ^<Cmd>call MakeWrapper("'", "'", 2)<CR>g@g_
au vimenter * nn [[ ^<Cmd>call MakeWrapper('[', ']', 1)<CR>g@g_

au vimenter * vn ( <Cmd>call MakeWrapper('(', ')', 2)<CR>g@
au vimenter * vn ) <Cmd>call MakeWrapper('(', ')', 2, 'block')<CR>g@
au vimenter * vn { <Cmd>call MakeWrapper('{', '}', 2)<CR>g@
au vimenter * vn } <Cmd>call MakeWrapper('{', '}', 2, 'block')<CR>g@
au vimenter * vn [ <Cmd>call MakeWrapper('[', ']', 1)<CR>g@
au vimenter * vn ] <Cmd>call MakeWrapper('[', ']', 1, 'block')<CR>g@
au vimenter * vn " <Cmd>call MakeWrapper('"', '"', 2)<CR>g@
au vimenter * vn ' <Cmd>call MakeWrapper("'", "'", 2)<CR>g@

" au vimenter * nn (( 0<Cmd>vim9cmd &operatorfunc = util.MakeWrapper('(', ')', 2)<CR>g@$
" au vimenter * nn {{ 0<Cmd>vim9cmd &operatorfunc = util.MakeWrapper('{', '}', 2)<CR>g@$
" au vimenter * nn "" 0<Cmd>vim9cmd &operatorfunc = util.MakeWrapper('"', '"', 2)<CR>g@$
" au vimenter * nn '' 0<Cmd>vim9cmd &operatorfunc = util.MakeWrapper("'", "'", 2)<CR>g@$
" au vimenter * nn [[ 0<Cmd>vim9cmd &operatorfunc = util.MakeWrapper('[', ']', 1)<CR>g@$

au VimEnter * nn <c-g> <ScriptCmd>let &operatorfunc=s:util.SendKeys<CR>g@$
au VimEnter * vn <c-g> <ScriptCmd>let &operatorfunc=s:util.SendKeys<CR>g@

au VimEnter * nn cd <ScriptCMD>call s:util.Quick_CD()<CR>

" au User RunModeTrigger   call RunMode()
" nn <leader>r :doautocmd User RunModeTrigger<CR>
au VimEnter * nn <silent> <leader>g <CMD>GrepModeOper<CR>g@
au VimEnter * vn <silent> <leader>g <CMD>GrepModeOper<CR>g@
au VimEnter * nn <silent> <leader>ig <CMD>GrepModeEdit<CR>q:
au VimEnter * nn <silent> <leader>r <CMD>RunMode<CR>
au VimEnter * nn <silent> <leader>ir <CMD>RunModeWithArgs<CR>
au VimEnter * nn <silent> <leader>sr <CMD>RunModeStrict<CR>
au VimEnter * nn <silent> <leader>d <CMD>DebugMode<CR>
au VimEnter * nn <silent> <leader>py <CMD>MypyMode<CR>

au VimEnter * source ~/.vim/functions/mode.vim

" au VimEnter * nn  gp <ScriptCmd>call s:util.MatchPairManager.GotoAnther()<CR>
" au VimEnter * nn  gh <ScriptCmd>call s:util.MatchPairManager.GotoLeft()<CR>
" au VimEnter * nn  gl <ScriptCmd>call s:util.MatchPairManager.GotoRight()<CR>
" au VimEnter * vn  gp <ScriptCmd>call s:util.MatchPairManager.GotoAnther()<CR>
" au VimEnter * vn  gh <ScriptCmd>call s:util.MatchPairManager.GotoLeft()<CR>
" au VimEnter * vn  gl <ScriptCmd>call s:util.MatchPairManager.GotoRight()<CR>
" au VimEnter * ono  gp <ScriptCmd>call s:util.MatchPairManager.GotoAnther()<CR>
" au VimEnter * ono  gh <ScriptCmd>call s:util.MatchPairManager.GotoLeft()<CR>
" au VimEnter * ono  gl <ScriptCmd>call s:util.MatchPairManager.GotoRight()<CR>
" au VimEnter * nn  %  <ScriptCmd>call s:util.PercentSign()<CR>
" au VimEnter * ono ig <ScriptCmd>call s:util.PercentSign1()<CR>
" au VimEnter * ono ag <ScriptCmd>call s:util.PercentSign2()<CR>
" au VimEnter * vn  ig <ScriptCmd>call s:util.PercentSign1()<CR>
" au VimEnter * vn  ag <ScriptCmd>call s:util.PercentSign2()<CR>
" au VimEnter * nn  gr <ScriptCmd>call s:util.ReplacePairs()<CR>

au CursorMoved  * call s:util.BlankIndentDrawerManager.Draw()
" au CursorMovedI * call s:util.BlankIndentDrawerManager.Draw()
" au CursorMoved  * call s:util.MatchPairManager.PercentSign()
" au CursorMovedI * call s:util.MatchPairManager.PercentSign()
aug end
" }}}


func! Eatchar(pat)
    let c = nr2char(getchar(0))
    return (c =~ a:pat) ? '' : c
endfunction

function! Expand(pat)
    if s:util.Cword('[^[:space:]]') ==# ''
        return a:pat .. "\<space>"
    else
        return "\<space>" .. a:pat .. "\<space>"
    endif
endfunction

function! ParseLine(row)
    if a:row <=# 1
        return ''
    endif
    return getline(a:row - 1)
endfunction

function! GuessExand()
    return s:util.GuessExand()
endfunction

function! RustGuessExpand()
    return s:util.RustGuessExpand()
endfunction

function! CppGuessExpand()
    return s:util.CppGuessExpand()
endfunction

function! MakeWrapper(left, right, stop, force_type = '')
    if a:force_type !=# ''
        let &operatorfunc = {type -> s:util.WrapOper(a:force_type, a:left, a:right, a:stop)}
    else
        let &operatorfunc = {type -> s:util.WrapOper(type, a:left, a:right, a:stop)}
    endif
endfunction
" }}}

function ScrollPopup(up=0)
  if (len(popup_list()) >= 1)
    let [row,    col]    = [screenrow(),     screencol()]
    let [condi1, condi2] = [popup_locate(row - 1, col), popup_locate(row + 1, col)]
    if condi1 !=# 0
        let popid = condi1
    elseif condi2 !=# 0
        let popid = condi2
    else
        return
    endif

    let firstline = popup_getoptions(popid)['firstline']
    if a:up
        call popup_setoptions(popid, {'firstline': max([1, firstline-1])})
    else
        call popup_setoptions(popid, {'firstline': firstline + 1})
    endif
  endif
endfunc


" nn <silent> <c-k> <CMD>silent! call CocActionAsync('doHover')<CR>

aug Coc
autocmd!

au CursorHold * if exists(":CocInfo") && CocActionAsync('hasProvider', 'hover') && (popup_list()->len() ==# 0)  && (CocAction('getHover') !=# []) | silent! call CocActionAsync('doHover') | echo coc#pum#visible() | endif

au VimEnter *  ino <silent> <expr> <c-n> coc#pum#visible() ? coc#pum#next(1) : coc#refresh()
au VimEnter *  ino <silent> <expr> <c-p> coc#pum#visible() ? coc#pum#prev(1) : coc#refresh()
"au VimEnter *  ino <silent> <c-j> <Cmd>call ScrollPopup(0)<CR>
"au VimEnter *  ino <silent> <c-k> <Cmd>call ScrollPopup(1)<CR>
" au VimEnter *  no <silent> <c-j> <Cmd>call ScrollPopup(0)<CR>
" au VimEnter *  no <silent> <c-k> <Cmd>call ScrollPopup(1)<CR>
au VimEnter *  no gd <plug>(coc-definition)
au VimEnter *  no gk <Cmd>call CocAction('definitionHover')<CR>

" coc jump
au VimEnter * nn <leader>n <Plug>(coc-rename)
au VimEnter * nn <c-p> <Plug>(coc-diagnostic-prev)
au VimEnter * nn <c-n> <Plug>(coc-diagnostic-next)
aug end
