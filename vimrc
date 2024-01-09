"                ███╗   ███╗██╗   ██╗██╗   ██╗██╗███╗   ███╗██████╗  ██████╗
"                ████╗ ████║╚██╗ ██╔╝██║   ██║██║████╗ ████║██╔══██╗██╔════╝
"                ██╔████╔██║ ╚████╔╝ ██║   ██║██║██╔████╔██║██████╔╝██║
"                ██║╚██╔╝██║  ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║██╔══██╗██║
"                ██║ ╚═╝ ██║   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║██║  ██║╚██████╗
"                ╚═╝     ╚═╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝

" Leader map
let mapleader = ","
if !exists("g:colorscheme")
    colorscheme onedark
    syntax      on
    let g:colorscheme   = 'onedark'
    let g:airline_theme = 'onedark'
    call system("dunstify -I /usr/share/icons/Papirus/48x48/apps/vim.svg rongzi  welcome to vim")
endif

"call airline#update_statusline()
set nocp
set concealcursor=ni
set conceallevel=2

" set smartindent
set eventignore+=FocusGained
set confirm
set cursorline
set encoding=utf-8
set expandtab
set fillchars=vert:┃
" set fillchars=vert:│
set list
set listchars=leadmultispace:│\ \ \ ,trail:-,precedes:>,extends:<,tab:⏐\ 
set lazyredraw
set linebreak
set nohlsearch
set rnu nu
set scrolloff=7
set shiftwidth=4
set showcmd
set smoothscroll
" set smarttab
set softtabstop=4
set synmaxcol=196
set autochdir
set termguicolors
set tabstop=4
set redrawtime=512
set ignorecase
set nowrap
set notimeout
"set timeoutlen=500
set ttimeout
set ttimeoutlen=128
set ttyfast
set virtualedit=NONE
set textwidth=256
set helplang=cn
set termwinsize=13*0
" set nu ru ai si ts=4 sw=4
" vim buffer tab open-tab
"     <c-[np]> <c-[ey]> <c-t>
" tmux buffer tab open-tab
"     <alt-[up,down,left,right]> <alt-[np]> <c-w>t


"  ██████╗    ██╗ ██████╗██████╗ ██████╗
" ██╔════╝   ██╔╝██╔════╝██╔══██╗██╔══██╗
" ██║       ██╔╝ ██║     ██████╔╝██████╔╝
" ██║      ██╔╝  ██║     ██╔═══╝ ██╔═══╝
" ╚██████╗██╔╝   ╚██████╗██║     ██║
"  ╚═════╝╚═╝     ╚═════╝╚═╝     ╚═╝
" C / CPP filetype script settings--------<++>------------{{{
aug C
autocmd!
au filetype c,cpp call system('dunstify -I /usr/share/icons/Papirus/48x48/apps/vim.svg C "using C syntax"')
au filetype c,cpp ino <buffer> ; <ESC>A;
au filetype c,cpp ino <buffer> } {}<left>
au filetype c,cpp ino <buffer> <F10> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

" au filetype c ino <cr> <esc>o
" au filetype c ino <c-h> <left>
" au filetype c ino <c-l> <right>
" au filetype c ino <c-j> <down>
" au filetype c ino <c-k> <up>
"
au filetype c,cpp ino <silent> <buffer> { <c-R>=AddSeprator()<CR><right>{<CR>}<Esc>O
"au filetype c,cpp ino <silent> <buffer> { <right>{<CR>}<Esc>O
"au filetype c,cpp ino <buffer> { <esc>A{<CR><++>}<ESC>O
au filetype c,cpp ino <buffer> <leader>m /*    */<esc>4<left>a
au filetype c,cpp ino <buffer> <leader><leader> <space>= 0,<space>
" # au filetype c,cpp nn <leader>r :w!<CR>:!cc %<CR><CR>:ter<CR>
au filetype c,cpp nn <buffer> <F10> i0, 1, 2, 3, 4, 5, 6, 7, 8, 9<Esc>
au filetype c,cpp nn <buffer> <F1> :syntax clear \|\| syntax on<CR>
au filetype c,cpp nn <buffer> <leader>m gI// <esc>

" ABBREVIATION
au filetype c,cpp inorea <silent> <buffer> itn      int
au filetype c,cpp inorea <silent> <buffer> retrun   return
au filetype c,cpp inorea <silent> <buffer> retunr   return
au filetype c,cpp inorea <silent> <buffer> reutrn   return
au filetype c,cpp inorea <silent> <buffer> for    for ( <++>; <++>; <++> )<CR>{}<left><CR><esc>O<++><esc>2k0f<cf>
au filetype c,cpp inorea <silent> <silent> <buffer> while  while ( )<left><left>
au filetype c,cpp inorea <silent> <silent> <buffer> if     if ( )<left><left>
au filetype c,cpp inorea <silent> <buffer> #i     # include <><left><C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> #I     # include <><left><C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> mm       main(int arg_number, char **arg_value)
au filetype c,cpp inorea <silent> <buffer> pp       printf("", <++>);<c-o>F"<C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> ss       scanf("",  <++>);<c-o>F"<C-R>=Eatchar('\s')<CR>
au filetype c,cpp inorea <silent> <buffer> kd       %d
au filetype c,cpp inorea <silent> <buffer> kf       %f
au filetype c,cpp inorea <silent> <buffer> kc       %c
au filetype c,cpp inorea <silent> <buffer> ks       %s
au filetype c,cpp inorea <silent> <buffer> klf      %lf
au filetype c,cpp inorea <silent> <buffer> kld      %ld
au filetype c,cpp inorea <silent> <buffer> klld     %lld
au filetype c,cpp inorea <silent> <buffer> kllf     %llf
au filetype c,cpp inorea <silent> <buffer> fuck     Are you alright?

"  <tab> and <space> visualised
au filetype c,cpp         setl    cindent
au BufEnter *.c,*.h,*.cpp highlight link Conceal Keyword
aug end
" }}}


" ██████╗ ██╗   ██╗████████╗██╗  ██╗ ██████╗ ███╗   ██╗
" ██╔══██╗╚██╗ ██╔╝╚══██╔══╝██║  ██║██╔═══██╗████╗  ██║
" ██████╔╝ ╚████╔╝    ██║   ███████║██║   ██║██╔██╗ ██║
" ██╔═══╝   ╚██╔╝     ██║   ██╔══██║██║   ██║██║╚██╗██║
" ██║        ██║      ██║   ██║  ██║╚██████╔╝██║ ╚████║
" ╚═╝        ╚═╝      ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
" python filetype script settings--------<++>------------{{{
aug python
autocmd!
" au BufNewFile *.py i#date:<C-r>=strftime("20%y/%m/%d/%A")
" au BufNewFile *.py i#coding=UTF-8<Enter>
" au BufNewFile *.py i#time:<C-r>=strftime("%H:%m")

au filetype python call system('dunstify -I /usr/share/icons/Papirus/64x64/apps/python3.10.svg python "using python syntax"')
au filetype python ino <buffer> ; <Esc>A:
au filetype python ino <buffer> # #<space><left><right>
" au filetype python ino <buffer> , ,<space><left><right>


au filetype python nn <buffer> <F1> :syntax clear \|\| syntax on<CR>
" Comment the line
au filetype python vn <buffer> <leader>m <C-v>0I# <esc>
au filetype python nn <buffer> <leader>m <C-v>0I# <esc>

" au filetype python ono <buffer> ( :<C-u>normal!t)lvi(<cr>

" au filetype python ia <buffer> if if:<left>
" au filetype python ia <buffer> for for:<left>
" au filetype python ia <buffer> else else:<left>
au filetype python ia <buffer> while  while:<left>
au filetype python ia <buffer> def    def:<left>
au filetype python ia <buffer> class  class:<left>
au filetype python ia <buffer> lambda lambda:<left>
au filetype python ia <buffer> lamdba lambda:<left>
au filetype python ia <buffer> ret    return
au filetype python ia <buffer> @@     1398881912@qq.com
au filetype python ia <buffer> pirnt  print

au BufEnter *.py highlight link Conceal Keyword
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
au filetype vim call system('dunstify -I /usr/share/icons/Papirus/48x48/apps/vim.svg vim "using vim syntax"')
au filetype vim nn <silent> <buffer> <leader>m <c-v>0I" <esc>
au filetype vim vn <silent> <buffer> <leader>m <C-v>0I" <esc>
au filetype vim let maplocalleader = "1"
au filetype vim setl foldmethod=marker
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
au TerminalOpen * tno <buffer> <leader>jk <c-w>N
au TerminalOpen * tno <buffer> <leader>k  <c-w>k
au TerminalOpen * setl nornu nonu
au TerminalOpen * setl nolist
" au TerminalOpen * :vertical resize -7
aug end
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
""autocmd StdinReadPre * let s:std_in=1
" au BufWinEnter * if argc() == 0 && !exists('s:std_in') |tt|endif

" " number in front of lines
" au VimEnter * ino <c-@> <Nop>

" replace  { [
" au BufEnter * call ChangeDirectory()
au BufEnter * call ChangeSrc()

" INSERT mode
au VimEnter * let &t_SI = "\<Esc>[5 q" . "\<Esc>]12;white\x8"
" REPLACE mode
au VimEnter * let &t_SR = "\<Esc>[3 q" . "\<Esc>]12;white\x7"
" NORMAL mode
au VimEnter * let &t_EI = "\<Esc>[2 q" . "\<Esc>]12;gray\x7"

au VimEnter * filetype on
au VimEnter * syntax   on
" au BufEnter * match Comment / /
au VimEnter * nn /    :set incsearch hlsearch<CR>/\v
"au QuickFixCmdPre *  syntax
"au VimEnter * nn <silent> <CR> :call ChangeDirectory()<CR>

" swich to the head or the end
au VimEnter * nn  <c-h>      ^
au VimEnter * nn  <c-l>      g_
au VimEnter * nn  <c-j>      ;
au VimEnter * nn  <c-k>      zz
au VimEnter * nn  <silent>   <c-p>       :bnext<CR>
au VimEnter * nn  <silent>   <c-n>       :bprev<CR>
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
au VimEnter * ono <c-l>      g_
" au VimEnter * match Comment /^ \+/
" fold method
au VimEnter * nn s  <Nop>
au VimEnter * nn ff zA
au Vimenter * nn fk zM
au VimEnter * nn fj zR

" edit $myvimrc
au VimEnter * nn <leader>ev :vsplit $MYVIMRC<CR>
au VimEnter * nm <leader>sv :w<CR>:source $MYVIMRC<CR>

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
au VimEnter * nn <leader>jh :cd ~<CR>
au VimEnter * nn <leader>jd :cd ~/Downloads<CR>
au VimEnter * nn <leader>jc :cd ~/.config<CR>
au VimEnter * nn <leader>jl :cd ~/.Lectures<CR>

"cmap 1 !
au VimEnter * nn gp   %
au VimEnter * nn w    <c-w>
au VimEnter * nn <BS> :set   hlsearch! incsearch! \| set hlsearch?<CR>

" terminal
" au VimEnter * nn <leader>r :horizontal bo terminal++close bash -rcfile ~/.my_bashrc<CR>
" au VimEnter * nn <leader>r :horizontal bo terminal++close<CR>
" au VimEnter * nn <leader>t :vertical terminal++close<CR>
au VimEnter * nn <leader>i :horizontal bo terminal++close python3<CR>

" save the file in the buffer
" au VimEnter * nn S :w<CR>
au VimEnter * nn S     :s/
au VimEnter * nn <C-s> :w<CR>

au VimEnter * nn  <F2> :put=system('sed      \"s/\(.*\)/{\1}/g\" <(seq -s \", \" 0 10)')<left><left><left>
au VimEnter * ino <F2> <Esc>:put=system('sed \"s/\(.*\)/{\1}/g\" <(seq -s \", \" 0 10)')<left><left><left>

" auto complete the () <> [] {}
au VimEnter * ino (  ()<left>
au VimEnter * ino [  []<left>
au VimEnter * ino {  {}<left>
au VimEnter * ino '  ''<left>
au VimEnter * ino "  ""<left>
au VimEnter * ino __ ____<left><left>

" surround the word in the insert mode
au VimEnter * ino <leader>' <Esc>viWA'<esc>Bi'<esc>ela
au VimEnter * ino <leader>" <Esc>viWA"<esc>Bi"<esc>ela
au VimEnter * ino <leader>( <Esc>viWA)<esc>Bi(<esc>ela
au VimEnter * ino <leader>[ <Esc>viWA]<esc>Bi[<esc>ela
au VimEnter * ino <leader>{ <Esc>viWA}<esc>Bi{<esc>ela
au VimEnter * ino <leader>< <Esc>viWA><esc>Bi<<esc>ela

" shortcuts
au VimEnter * ino jk    <esc>
au VimEnter * ino 即可  <esc>       " 使中文下可以使用<jk>退出插入模式
au VimEnter * ino <c-f> <right>
au VimEnter * ino <c-b> <left>
au VimEnter * ino <c-a> <Esc>I
au VimEnter * ino <c-e> <Esc>g_a
au VimEnter * ino <C-s> <Esc>:w<CR>

au VimEnter * cno <c-b> <left>
au VimEnter * cno <c-f> <right>
au VimEnter * cno <c-a> <c-b>

" Transform the word to UPPER-CASE
au VimEnter * ino <BS>     <Nop>
au VimEnter * ino <c-u>    <esc>viwUviwA
au VimEnter * ino <c-j>    <esc>A<CR>
au VimEnter * ino <c-c>    <Esc>
au VimEnter * ino <c-v>    <Esc>viw
" Turn the ; into <CR>
" au VimEnter * cno ; <CR>
" au VimEnter * nn  ; <CR>
" au VimEnter * in ; <Esc>o

" spell check
au VimEnter * nn  <silent> sc :setl  spell!<CR>
au VimEnter * ino <c-x> <Cmd>set spell<CR><c-x>s

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
au VimEnter * vn *     y:call SearchSelectedText()<CR>
au VimEnter * vn v     <Esc>

au VimEnter * inorea 123 {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
" Comment the line in visual mode
" vn " <c-v>0I" <esc>
au VimEnter * vn #    <c-v>0I#<space><esc>
au VimEnter * vn /    <C-v>0I//<space><esc>
au VimEnter * vn ;    <C-v>0I;<esc>
au VimEnter * vn <CR> !copy<CR>
au VimEnter * nn *    *N:set hlsearch<CR>
" return to the file .vimrc
au VimEnter * nn <leader>V :e $MYVIMRC<CR>

" return to the current directory
au VimEnter * nn <leader>e :e .<CR>

" use python3
au VimEnter * vn rp !python3<CR>

"In case that keyborad is sensitive
au VimEnter * vn <s-k>      <Nop>
au VimEnter * vn <s-j><s-j> <s-j>
au VimEnter * vn <s-j>      <Nop>
au VimEnter * vn <c-j>      ;
au VimEnter * vn <leader>c  :!~/.config/scripts/align<CR>
"au InsertCharPre * normal a<c-n>
aug END
" }}}


" ██████╗ ██╗     ██╗   ██╗ ██████╗       ██╗███╗   ██╗
" ██╔══██╗██║     ██║   ██║██╔════╝       ██║████╗  ██║
" ██████╔╝██║     ██║   ██║██║  ███╗█████╗██║██╔██╗ ██║
" ██╔═══╝ ██║     ██║   ██║██║   ██║╚════╝██║██║╚██╗██║
" ██║     ███████╗╚██████╔╝╚██████╔╝      ██║██║ ╚████║
" ╚═╝     ╚══════╝ ╚═════╝  ╚═════╝       ╚═╝╚═╝  ╚═══╝
"plug-in settings---------<++>-----------{{{
" NERDTree
" noremap <leader>t :NERDTreeToggle<CR>

" " Full Screen Set
" nn \| <esc>:call libcallnr('gvim_fullscreen.dll', 'ToggleFullscreen', 0)<CR>

" "" press F12 to change the scheme of the local window
" no <C-j>j <esc>:call libcallnr('gvim_fullscreen.dll', 'ToggleTransparency', "100,180")<CR>
" no <C-k>k <esc>:call libcallnr('gvim_fullscreen.dll', 'ToggleTransparency', "225,255")<CR>

" easymotion
nn <c-f> <plug>(easymotion-prefix)s

" filetype plugin on

call plug#begin()
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'
" Make sure you use single quotes
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" " If you don't have nodejs and yarn
" use pre build, add 'vim-plug' to the filetype list so vim-plug can update this plugin
" see: https://github.com/iamcco/markdown-preview.nvim/issues/50
" Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
" If you have nodejs
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }
call plug#end()
" }}}


"asm filetype script settings--------<++>------------{{{
aug asm
autocmd!
au filetype asm set foldlevel=10
au filetype asm set scrolloff=15
au filetype asm set noexpandtab
au filetype asm set shiftwidth=8
au filetype asm set softtabstop=8
au filetype asm set autoindent
au filetype asm set listchars=leadmultispace:⏐\ \ \ ,trail:-,precedes:>,extends:<,tab:\ \
au filetype asm vn  <buffer> <leader>m <C-v>0I; <esc>
aug end
" }}}


"man doc settings--------<++>------------{{{
aug man
autocmd!
" au filetype man only
au filetype man set nolist
au filetype man set noconfirm
au filetype man set foldlevel=10
au filetype man set laststatus=0
au filetype man set scrolloff=15
au filetype man nn  <buffer> d <c-d>
au filetype man nn  <buffer> u <c-u>
au filetype man nn  <buffer> q :q!<CR>
aug end
" }}}


"help doc settings--------<++>------------{{{
aug help
autocmd!
" au filetype man only
au filetype help setl nolist
au filetype help setl noconfirm
au filetype help setl scrolloff=17
aug end
" }}}


"markdown scripts settings--------<++>------------{{{
aug markdown
autocmd!
" au filetype man only
au filetype markdown ino <buffer> <leader>* ******<left><left><left>
au filetype markdown ino <buffer> g* ****<left><left>
au filetype markdown ino <buffer> * **<left>
au filetype markdown ino <buffer> ’ ``<left>
au filetype markdown ino <buffer> ‘ ``<left>
au filetype markdown ino <buffer> ' ``<left>
au filetype markdown ino <buffer> ～ ~~~~<left><left>
au filetype markdown nn  <buffer> <leader>t o\|<Tab><++><Tab>\|<Tab><++><Tab>\|<Tab><++><Tab>\|<Tab><++><Tab>\|<Esc>0/<++><CR>cf>
aug end
" }}}


"bash scripts settings--------<++>------------{{{
aug bash
autocmd!
" au filetype man only
au filetype bash,sh inorea <silent> <buffer> if  if [[<++> ]];then<CR>fi<Esc>?<++><CR>cw
au filetype bash,sh inorea <silent> <buffer> for for<++> in <++>;do<CR>done<Esc>0kf<cw
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
au  filetype sql inorea <buffer> databaSE   DATABASE
au  filetype sql inorea <buffer> defaulT    DEFAULT
au  filetype sql inorea <buffer> delete     DELETE
au  filetype sql inorea <buffer> desc       DESC
au  filetype sql inorea <buffer> distinct   DISTINCT
au  filetype sql inorea <buffer> drop       DROP
au  filetype sql inorea <buffer> else       ELSE
au  filetype sql inorea <buffer> end        END
au  filetype sql inorea <buffer> escape     ESCAPE
au  filetype sql inorea <buffer> exists     EXISTS
au  filetype sql inorea <buffer> foreigN    FOREIGN
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
au  filetype sql inorea <buffer> primarY    PRIMARY
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


" ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗███████╗
" ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝██╔════╝
" ███████╗██║     ██████╔╝██║██████╔╝   ██║   ███████╗
" ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║   ╚════██║
" ███████║╚██████╗██║  ██║██║██║        ██║   ███████║
" ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝   ╚══════╝
"vim filetype script settings--------<++>------------{{{
source /home/rongzi/.vim/functions/useful.vim
" }}}

