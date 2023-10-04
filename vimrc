"      ███╗   ███╗██╗   ██╗██╗   ██╗██╗███╗   ███╗██████╗  ██████╗
"      ████╗ ████║╚██╗ ██╔╝██║   ██║██║████╗ ████║██╔══██╗██╔════╝
"      ██╔████╔██║ ╚████╔╝ ██║   ██║██║██╔████╔██║██████╔╝██║
"      ██║╚██╔╝██║  ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║██╔══██╗██║
"      ██║ ╚═╝ ██║   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║██║  ██║╚██████╗
"      ╚═╝     ╚═╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝

"      ███╗   ███╗██╗   ██╗██╗   ██╗██╗███╗   ███╗██████╗  ██████╗
"      ████╗ ████║╚██╗ ██╔╝██║   ██║██║████╗ ████║██╔══██╗██╔════╝
"      ██╔████╔██║ ╚████╔╝ ██║   ██║██║██╔████╔██║██████╔╝██║
"      ██║╚██╔╝██║  ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║██╔══██╗██║
"      ██║ ╚═╝ ██║   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║██║  ██║╚██████╗
"      ╚═╝     ╚═╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝
" Leader map
let mapleader = ","
set nowrap
set nocp
set showcmd
set list
set listchars=leadmultispace:\|\ \ \ ,trail:-,precedes:>,extends:<,tab:\ \ 
" set listchars=leadmultispace:⏐\ \ \ ,trail:-,precedes:>,extends:<,tab:\ \ 
set ruler
set nowrap
set wildmenu
set cursorline
set rnu
set ignorecase
set encoding=utf-8
set scrolloff=5
" set termwinsize=10x0
set fillchars=vert:\|
set confirm

" highlight setting
set nohlsearch
set incsearch

" " share the clipboard
set clipboard=unnamed
set laststatus=2

" fold tab method
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab
set autoindent
set smartindent
set foldmethod=indent
" Better scrolling
set lz
" Comment the line in visual mode
vn # <c-v>0I# <esc>
vn " <c-v>0I" <esc> 
vn / <C-v>0I// <esc>

" use python3 socket
vn rp !python3<CR>

"In case that keyborad is sensitive
" vn <s-k> <Nop>
" Transform the word to UPPER-CASE
ino <BS> <Nop>
ino <c-u> <esc>viwUviwA
ino <c-j> <esc>A<CR>
ino : :

" swich to the head or the end
nn <c-h> ^
nn <c-l> g_
nn <c-j> <CR>
" " <Backspace> in insert mode
" ino <c-o> <BS>
" cno <c-o> <BS>


       
"   ____ 
"  / ___|
" | |    
" | |___ 
"  \____|
"        
"<++>
aug C
autocmd!
au filetype c,cpp ino ; <ESC>A;
au filetype c,cpp ino ( ()<left>
au filetype c,cpp ino " ""<left>
au filetype c,cpp ino ' ''<left>
" au filetype c ino { <esc>o{}<left><CR><esc>O
au filetype c,cpp ino { <esc>A{<CR>}<ESC>O
au filetype c,cpp ino } {}<left>
au filetype c,cpp ino [ []<left>
au filetype c,cpp ino <buffer> # #<space><left><right>

au filetype c,cpp ino <F10> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

" au filetype c ino <cr> <esc>o
" au filetype c ino <c-h> <left>
" au filetype c ino <c-l> <right>
" au filetype c ino <c-j> <down>
" au filetype c ino <c-k> <up>
au filetype c,cpp ino \\ /*    */<esc>4<left>a
" # au filetype c,cpp nn <leader>r :w!<CR>:!cc %<CR><CR>:ter<CR>
au filetype c,cpp nn <F10> i0, 1, 2, 3, 4, 5, 6, 7, 8, 9<Esc>

" ABBREVIATION
au filetype c,cpp inorea  for for (<++>; <++>; <++>) {}<left><CR><esc>O<++><esc>/<++><CR>ca<
au filetype c,cpp inorea  while while ( )<left><left>

au filetype c,cpp inorea if if ( )<left><left>
au filetype c,cpp inorea fuck abcd




"  <tab> and <space> visualised
au filetype c,cpp setl list
au filetype c,cpp setl cindent
aug end



" ██████╗ ██╗   ██╗████████╗██╗  ██╗ ██████╗ ███╗   ██╗
" ██╔══██╗╚██╗ ██╔╝╚══██╔══╝██║  ██║██╔═══██╗████╗  ██║
" ██████╔╝ ╚████╔╝    ██║   ███████║██║   ██║██╔██╗ ██║
" ██╔═══╝   ╚██╔╝     ██║   ██╔══██║██║   ██║██║╚██╗██║
" ██║        ██║      ██║   ██║  ██║╚██████╔╝██║ ╚████║
" ╚═╝        ╚═╝      ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
"<++>
aug python
autocmd!
" au BufNewFile *.py i#date:<C-r>=strftime("20%y/%m/%d/%A")
" au BufNewFile *.py i#coding=UTF-8<Enter>
" au BufNewFile *.py i#time:<C-r>=strftime("%H:%m")

" When typing ' =  -  +  /  *  % ', add spaces automatically
" au filetype python ino <buffer> + <space>+<space><left><right>
" au filetype python ino <buffer> - <space>-<space><left><right>
" au filetype python ino <buffer> * <space>*<space><left><right>
" au filetype python ino <buffer> / <space>/<space><left><right>
" au filetype python ino <buffer> % <space>%<space><left><right>
" au filetype python ino <buffer> = <space>=<space><left><right>
au filetype python :match Comment /^ \+\ze/
au filetype python ino <buffer> # #<space><left><right>
" au filetype python ino <buffer> , ,<space><left><right>

" auto complete the () <> [] {}
" au filetype python ino <buffer> < <><left>
au filetype python ino <buffer> ( ()<left>
au filetype python ino <buffer> [ []<left>
au filetype python ino <buffer> { {}<left>
au filetype python ino <buffer> ' ''<left>
au filetype python ino <buffer> " ""<left>
au filetype python ino <buffer> __ ____<left><left>


" surround the word in the insert mode
au filetype python ino <buffer> <leader>' <esc>viwA'<esc>bi'<esc>ela
au filetype python ino <buffer> <leader>" <esc>viwA"<esc>bi"<esc>ela
au filetype python ino <buffer> <leader>( <esc>viwA)<esc>bi(<esc>ela
au filetype python ino <buffer> <leader>[ <esc>viwA]<esc>bi[<esc>ela
au filetype python ino <buffer> <leader>{ <esc>viwA}<esc>bi{<esc>ela
au filetype python ino <buffer> <leader>< <esc>viwA><esc>bi<<esc>ela

" surround the word in the normal mode
au filetype python nn <buffer> <leader>' <esc>viwA'<esc>bi'<esc>el
au filetype python nn <buffer> <leader>" <esc>viwA"<esc>bi"<esc>el
au filetype python nn <buffer> <leader>( <esc>viwA)<esc>bi(<esc>el
au filetype python nn <buffer> <leader>[ <esc>viwA]<esc>bi[<esc>el
au filetype python nn <buffer> <leader>{ <esc>viwA}<esc>bi{<esc>el
au filetype python nn <buffer> <leader>< <esc>viwA><esc>bi<<esc>el



" Comment the line
au filetype python vn <buffer> <leader>c <C-v>0I# <esc>
au filetype python nn <buffer> <leader>c <C-v>0I# <esc>

au filetype python ono <buffer> ( :<C-u>normal!t)lvi(<cr>

au filetype python ia <buffer> if if:<left>
au filetype python ia <buffer> for for:<left>
" au filetype python ia <buffer> else else:<left>
au filetype python ia <buffer> while while:<left>
au filetype python ia <buffer> def def:<left>
au filetype python ia <buffer> class class:<left>
au filetype python ia <buffer> ret return
au filetype python ia <buffer> @@ 1398881912@qq.com
au filetype python ia <buffer> pirnt print


"  <tab> and <space> visualised
aug end






" ██╗   ██╗██╗███╗   ███╗
" ██║   ██║██║████╗ ████║
" ██║   ██║██║██╔████╔██║
" ╚██╗ ██╔╝██║██║╚██╔╝██║
"  ╚████╔╝ ██║██║ ╚═╝ ██║
"   ╚═══╝  ╚═╝╚═╝     ╚═╝
" <++>
aug vim 
autocmd!
au filetype vim  nn <leader>c I" <esc>
au filetype vim let maplocalleader = "1"
aug end


colorscheme onedark

" color scheme | font
set guifont:Consolas:h13

"  _                      _             _ 
" | |_ ___ _ __ _ __ ___ (_)_ __   __ _| |
" | __/ _ \ '__| '_ ` _ \| | '_ \ / _` | |
" | ||  __/ |  | | | | | | | | | | (_| | |
"  \__\___|_|  |_| |_| |_|_|_| |_|\__,_|_|
"<++>
aug terminal
autocmd!
au TerminalOpen * tno jk <c-w>N
au TerminalOpen * setl nornu nonu
au TerminalOpen * setl laststatus=2
au TerminalOpen * :resize -7
aug end


"  _   _                            _ 
" | \ | | ___  _ __ _ __ ___   __ _| |
" |  \| |/ _ \| '__| '_ ` _ \ / _` | |
" | |\  | (_) | |  | | | | | | (_| | |
" |_| \_|\___/|_|  |_| |_| |_|\__,_|_|
"                                     
" <++>
aug normal
autocmd!
""autocmd StdinReadPre * let s:std_in=1
" au BufWinEnter * if argc() == 0 && !exists('s:std_in') |tt|endif

" " number in front of lines
au VimEnter * ino <c-@> <Nop>

" replace  { [
au VimEnter * nn [ {
au VimEnter * nn ] }
au VimEnter * nn / :set hlsearch<CR>/
au VimEnter * nn * :set hlsearch<CR>*N

" fold method
au VimEnter * nn s <Nop>
au VimEnter * nn ff zA
au Vimenter * nn fk zM
au VimEnter * nn fj zR

" edit $myvimrc
au VimEnter * nn <leader>ev :vsplit $MYVIMRC<CR>
au VimEnter * nm <leader>sv :w<CR>:source $MYVIMRC<CR>

" tab site
au VimEnter * nn TT :tabnew<CR>
au VimEnter * nn th :-tabnext<CR>
au VimEnter * nn tl :+tabnext<CR>

" screen create
au VimEnter * nn <c-s><c-h> :set splitright<CR>:vsplit<CR>
au VimEnter * nn <c-s><c-l> :set nosplitright<CR>:vsplit<CR>
au VimEnter * nn <c-s><c-k> :set splitbelow<CR>:split<CR>
au VimEnter * nn <c-s><c-j> :set nosplitbelow<CR>:split<CR>

" screen switch
au VimEnter * nn wk <c-w>k
au VimEnter * nn wj <c-w>j
au VimEnter * nn wh <c-w>h
au VimEnter * nn wl <c-w>l

" screen switch
au VimEnter * nn <s-K> <c-w>K
au VimEnter * nn <s-J> <c-w>J
au VimEnter * nn <s-H> <c-w>H
au VimEnter * nn <s-L> <c-w>L

" screen size
au VimEnter * nn _ :resize -10<CR>
au VimEnter * nn + :resize +10<CR>
au VimEnter * nn - :vertical resize -10<CR>
au VimEnter * nn = :vertical resize +10<CR>

" cd to other directory quickly
au VimEnter * nn <leader>gh :cd ~<CR>
au VimEnter * nn <leader>gd :cd ~/Downloads<CR>
au VimEnter * nn <leader>gc :cd ~/.config<CR>
au VimEnter * nn <leader>gl :cd ~/.Lectures<CR>

"cmap 1 !
au VimEnter * nn w <c-w>
au VimEnter * nn <BS> :set hlsearch!\|set hlsearch?<CR>

" terminal
au VimEnter * nn <leader>r :horizontal bo terminal++close<CR>
au VimEnter * nn <leader>i :horizontal bo terminal++close python3<CR>

" save the file in the buffer 
au VimEnter * nn S :w<CR>

" shortcuts
au VimEnter * ino jk <esc>
au VimEnter * ino <c-f> <right>
au VimEnter * ino <c-b> <left>
au VimEnter * ino <c-a> <Esc>I
au VimEnter * ino <c-e> <Esc>A

" Turn the ; into <CR> 
" au VimEnter * cno ; <CR>
" au VimEnter * nn  ; <CR>
" au VimEnter * ino ; <esc>o

" spell check
au VimEnter * nn  sc :setl spell!<CR>
au VimEnter * ino <s-s><s-c> <c-x>s

" shortcuts switched
au VimEnter * nn  <space> :

" move easily by <c-h><c-l>
" au VimEnter * cno <c-a> <left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left>
au VimEnter * cno <BS><Nop>
au VimEnter * cno <c-f> <right>
au VimEnter * cno <c-b> <left>
au VimEnter * cno <c-i> <c-f>i<c-x><c-i>

" Anchor Point
au VimEnter * ino <leader>f <esc>/<++><CR>ca<
au VimEnter * nn  <leader>f /<++><CR>

au VimEnter * vno \| :!
au VimEnter * vno s :s/
au VimEnter * nn <leader>t :set termguicolors!<CR>

aug END

" enable true color
set termguicolors
set nu ru ai si ts=4 sw=4

" return to the file .vimrc
nn <leader>v :e $MYVIMRC<CR>

" return to the current directory
nn <leader>e :e .<CR>

" return to the /program files (x86)/
" nn <leader>p :e/Program Files (x86)/Vim/My_Python<CR>
"



" ██████╗ ██╗     ██╗   ██╗ ██████╗       ██╗███╗   ██╗
" ██╔══██╗██║     ██║   ██║██╔════╝       ██║████╗  ██║
" ██████╔╝██║     ██║   ██║██║  ███╗█████╗██║██╔██╗ ██║
" ██╔═══╝ ██║     ██║   ██║██║   ██║╚════╝██║██║╚██╗██║
" ██║     ███████╗╚██████╔╝╚██████╔╝      ██║██║ ╚████║
" ╚═╝     ╚══════╝ ╚═════╝  ╚═════╝       ╚═╝╚═╝  ╚═══╝
"<++>
" NERDTree
nn tt :NERDTreeToggle<CR>
" 
" " Full Screen Set
" nn \| <esc>:call libcallnr('gvim_fullscreen.dll', 'ToggleFullscreen', 0)<CR>
" 
" "" press F12 to change the scheme of the local window
" no <C-j>j <esc>:call libcallnr('gvim_fullscreen.dll', 'ToggleTransparency', "100,180")<CR>
" no <C-k>k <esc>:call libcallnr('gvim_fullscreen.dll', 'ToggleTransparency', "225,255")<CR>
" 
" easymotion
map <leader>s <plug>(easymotion-prefix)
nm f ,ss

filetype plugin on

call plug#begin()
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'
" Make sure you use single quotes

" " Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
" Plug 'junegunn/vim-easy-align'
" 
" " Any valid git URL is allowed
" Plug 'https://github.com/junegunn/vim-github-dashboard.git'
" 
" " Multiple Plug commands can be written in a single line using | separators
" Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
" 
" " On-demand loading
" Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
" Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
" 
" " Using a non-default branch
" Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
" 
" " Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
" Plug 'fatih/vim-go', { 'tag': '*' }
" 
" If you don't have nodejs and yarn
" use pre build, add 'vim-plug' to the filetype list so vim-plug can update this plugin
" see: https://github.com/iamcco/markdown-preview.nvim/issues/50
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
" If you have nodejs and yarn
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }

" " Plugin options
" Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }
" 
" " Plugin outside ~/.vim/plugged with post-update hook
" Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
" If you don't have nodejs and yarn
" use pre build, add 'vim-plug' to the filetype list so vim-plug can update this plugin
" see: https://github.com/iamcco/markdown-preview.nvim/issues/50

" If you don't have nodejs and yarn
" use pre build, add 'vim-plug' to the filetype list so vim-plug can update this plugin
" see: https://github.com/iamcco/markdown-preview.nvim/issues/50



" " Unmanaged plugin (manually installed and updated)
" Plug '~/my-prototype-plugin'
" 
" " Initialize plugin system
" " - Automatically executes `filetype plugin indent on` and `syntax enable`.
call plug#end()
" You can revert the settings after the call like so:
"   filetype indent off   " Disable file-type-specific indentation
"   syntax off            " Disable syntax highlighting

" " shut down the error warning
setl vb t_vb=
aug md
autocmd!
au filetype markdown nnoremap <C-p> <Plug>MarkdownPreviewToggle
aug end

"                _       _
"  ___  ___ _ __(_)_ __ | |_ ___
" / __|/ __| '__| | '_ \| __/ __|
" \__ \ (__| |  | | |_) | |_\__ \
" |___/\___|_|  |_| .__/ \__|___/
"                 |_|
" INSERT mode
let &t_SI = "\<Esc>[5 q" . "\<Esc>]12;blue\x7"
" REPLACE mode
let &t_SR = "\<Esc>[3 q" . "\<Esc>]12;black\x7"
" NORMAL mode
let &t_EI = "\<Esc>[2 q" . "\<Esc>]12;green\x7"
