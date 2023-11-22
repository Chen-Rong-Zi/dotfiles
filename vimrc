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
" Better scrolling
" fold tab method
" highlight setting
set nocp
set concealcursor=ni
set conceallevel=2
set confirm
set cursorline
set encoding=utf-8
set expandtab
set fillchars=vert:┃
set foldmethod=indent
set ignorecase
set incsearch
set laststatus=2
set list
set listchars=leadmultispace:⏐\ \ \ ,trail:-,precedes:>,extends:<,tab:⏐\ 
set lazyredraw
set nohlsearch
set rnu nu
set scrolloff=7
set shiftwidth=4
set showcmd
" set smarttab
set softtabstop=4
set synmaxcol=175
set termguicolors
set tabstop=4
set redrawtime=1000
set nowrap
set timeoutlen=280
set ttimeoutlen=1000
set ttyfast
" set termwinsize=10x0
" set nu ru ai si ts=4 sw=4

" Comment the line in visual mode
vn # <c-v>0I# <esc>
vn " <c-v>0I" <esc>
vn / <C-v>0I// <esc>
vn ; <C-v>0I;<esc>
vn <CR> !copy<CR>
nn * *N:set hlsearch<CR>

" use python3 socket
vn rp !python3<CR>

"In case that keyborad is sensitive
vn <s-k> <Nop>
vn <c-j> ;
" Transform the word to UPPER-CASE
ino <BS> <Nop>
ino <c-u> <esc>viwUviwA
ino <c-j> <esc>A<CR>

" swich to the head or the end
nn <c-h> ^
nn <c-l> g_
nn <c-j> ;
nn <c-k> zz
nn <s-j> <NOP>
nn <s-j><s-j> <s-j>
nn <s-k> <Nop>
nn Y yg_
" " <Backspace> in insert mode
" ino <c-o> <BS>
" cno <c-o> <BS>


"   ____ 
"  / ___|
" | |    
" | |___ 
"  \____|
"<++>
aug C
autocmd!
au filetype c,cpp ino <buffer> ; <ESC>A;
au filetype c,cpp ino <buffer> # # <left><right>
au filetype c,cpp ino <buffer> } {}<left>

au filetype c,cpp ino <buffer> <F10> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

" au filetype c ino <cr> <esc>o
" au filetype c ino <c-h> <left>
" au filetype c ino <c-l> <right>
" au filetype c ino <c-j> <down>
" au filetype c ino <c-k> <up>
au filetype c,cpp ino <buffer> { <esc>A{<CR>}<ESC>O
au filetype c,cpp ino <buffer> \\ /*    */<esc>4<left>a
au filetype c,cpp ino <buffer> <leader><leader> <space>= 0,<space>
" # au filetype c,cpp nn <leader>r :w!<CR>:!cc %<CR><CR>:ter<CR>
au filetype c,cpp nn <buffer> <F10> i0, 1, 2, 3, 4, 5, 6, 7, 8, 9<Esc>
au filetype c,cpp nn <buffer> <F1> :syntax clear \|\| syntax on<CR>
au filetype c,cpp vn <buffer> <leader>c <C-v>0I// <esc>

" ABBREVIATION
au filetype c,cpp inorea <buffer> for for (<++>; <++>; <++>){}<left><CR><esc>O<++><esc>/<++><CR>ca<
au filetype c,cpp inorea <buffer> while while ( )<left><left>
au filetype c,cpp inorea <buffer> if if ( )<left><left>
au filetype c,cpp inorea <buffer> fuck Are you alright?

"  <tab> and <space> visualised
au filetype c,cpp setl cindent
" au BufEnter *.c set filetype=c
" au BufEnter *.h set filetype=c
au BufEnter *.c,*.h,*.cpp highlight link Conceal Keyword
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

au filetype python ino <buffer> ; <Esc>A:
au filetype python ino <buffer> # #<space><left><right>
" au filetype python ino <buffer> , ,<space><left><right>


au filetype python nn <F1> :syntax clear \|\| syntax on<CR>
" Comment the line
au filetype python vn <buffer> <leader>c <C-v>0I# <esc>
au filetype python nn <buffer> <leader>c <C-v>0I# <esc>

au filetype python ono <buffer> ( :<C-u>normal!t)lvi(<cr>

" au filetype python ia <buffer> if if:<left>
" au filetype python ia <buffer> for for:<left>
" au filetype python ia <buffer> else else:<left>
au filetype python ia <buffer> while while:<left>
au filetype python ia <buffer> def def:<left>
au filetype python ia <buffer> class class:<left>
au filetype python ia <buffer> lambda lambda:<left>
au filetype python ia <buffer> lamdba lambda:<left>
au filetype python ia <buffer> ret return
au filetype python ia <buffer> @@ 1398881912@qq.com
au filetype python ia <buffer> pirnt print

au BufEnter *.py highlight link Conceal Keyword
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
au filetype vim  nn <buffer> <leader>c I" <esc>
au filetype vim let maplocalleader = "1"
aug end
colorscheme onedark

" color scheme | font
" set guifont:Consolas:h13

"  _                      _             _ 
" | |_ ___ _ __ _ __ ___ (_)_ __   __ _| |
" | __/ _ \ '__| '_ ` _ \| | '_ \ / _` | |
" | ||  __/ |  | | | | | | | | | | (_| | |
"  \__\___|_|  |_| |_| |_|_|_| |_|\__,_|_|
"<++>
aug terminal
autocmd!
au TerminalOpen * tno <leader>jk <c-w>N
au TerminalOpen * tno <leader>k <c-w>k
au TerminalOpen * setl nornu nonu
au TerminalOpen * setl nolist
au TerminalOpen * :resize -7
" au TerminalOpen * :vertical resize -7
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
" au VimEnter * ino <c-@> <Nop>

" replace  { [
au BufWinEnter * call ChangeDirectory()
" au BufEnter * match Comment / /
au VimEnter * nn / :set hlsearch<CR>/
au VimEnter * nn <CR> :cd %:h<CR>

" auto complete the () <> [] {}
au VimEnter * ino ( ()<left>
au VimEnter * ino [ []<left>
au VimEnter * ino { {}<left>
au VimEnter * ino ' ''<left>
au VimEnter * ino " ""<left>
au VimEnter * ino __ ____<left><left>

" surround the word in the insert mode
au VimEnter * ino <leader>' <Esc>viWA'<esc>Bi'<esc>ela
au VimEnter * ino <leader>" <Esc>viWA"<esc>Bi"<esc>ela
au VimEnter * ino <leader>( <Esc>viWA)<esc>Bi(<esc>ela
au VimEnter * ino <leader>[ <Esc>viWA]<esc>Bi[<esc>ela
au VimEnter * ino <leader>{ <Esc>viWA}<esc>Bi{<esc>ela
au VimEnter * ino <leader>< <Esc>viWA><esc>Bi<<esc>ela

" surround the word in the normal mode
au VimEnter * nn <leader>' viWA'<esc>Bi'<esc>el
au VimEnter * nn <leader>" viWA"<esc>Bi"<esc>el
au VimEnter * nn <leader>( viWA)<esc>Bi(<esc>el
au VimEnter * nn <leader>[ viWA]<esc>Bi[<esc>el
au VimEnter * nn <leader>{ viWA}<esc>Bi{<esc>el
au VimEnter * nn <leader>< viWA><esc>Bi<<esc>el

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
au VimEnter * nn <leader>k <c-w>K
au VimEnter * nn <leader>j <c-w>J
au VimEnter * nn <leader>h <c-w>H
au VimEnter * nn <leader>l <c-w>L

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
au VimEnter * nn <c-w>c <Nop>
au VimEnter * nn <BS> :set hlsearch!\|set hlsearch?<CR>

au VimEnter * nn <F2> :r!rn 0 10 1

" terminal
" au VimEnter * nn <leader>r :horizontal bo terminal++close bash -rcfile ~/.my_bashrc<CR>
au VimEnter * nn <leader>r :horizontal bo terminal++close<CR>
au VimEnter * nn <leader>t :vertical terminal++close<CR>
au VimEnter * nn <leader>i :horizontal bo terminal++close python3<CR>

" save the file in the buffer 
" au VimEnter * nn S :w<CR>
au VimEnter * nn S :s/
au VimEnter * nn <C-s> :w<CR>

" shortcuts
au VimEnter * ino jk <esc>
au VimEnter * ino <c-f> <right>
au VimEnter * ino <c-b> <left>
au VimEnter * ino <c-a> <Esc>I
au VimEnter * ino <c-e> <Esc>A

au VimEnter * cno <c-b> <left>
au VimEnter * cno <c-f> <right>
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

" Anchor Point
au VimEnter * ino <leader>f <esc>/<++><CR>ca<
au VimEnter * nn  <leader>f /<++><CR>
au VimEnter * nn  <leader>ss :%s/

au VimEnter * vn \| :!
au VimEnter * vn s :s/
au VimEnter * vn <c-h> ^
au VimEnter * vn <c-l> g_
au VimEnter * vn * y/\V<C-R>=escape(@",'/\')<CR><CR>:set hlsearch<CR>N

" au VimEnter * match Comment /^ \+/
aug END
" enable true color

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
" noremap <leader>t :NERDTreeToggle<CR>
" 
" " Full Screen Set
" nn \| <esc>:call libcallnr('gvim_fullscreen.dll', 'ToggleFullscreen', 0)<CR>
" 
" "" press F12 to change the scheme of the local window
" no <C-j>j <esc>:call libcallnr('gvim_fullscreen.dll', 'ToggleTransparency', "100,180")<CR>
" no <C-k>k <esc>:call libcallnr('gvim_fullscreen.dll', 'ToggleTransparency', "225,255")<CR>
" 
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

aug asm
autocmd!
au filetype asm set foldlevel=10
au filetype asm set scrolloff=15
au filetype asm set noexpandtab
au filetype asm set shiftwidth=8
au filetype asm set softtabstop=8
au filetype asm set autoindent
au filetype asm set autoindent
au filetype asm set list
au filetype asm set listchars=leadmultispace:⏐\ \ \ ,trail:-,precedes:>,extends:<,tab:\ \ 
au filetype asm vn <buffer> <leader>c <C-v>0I; <esc>
aug end

aug md
autocmd!
au filetype markdown nnoremap <C-p> <Plug>MarkdownPreviewToggle
aug end

aug man
autocmd!
au filetype man only
au filetype man set nolist
au filetype man set foldlevel=10
au filetype man set laststatus=0
au filetype man set scrolloff=15
au filetype man nn d <c-d>
au filetype man nn u <c-u>
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


" runtime! ftplugin/man.vim
source ~/.vim/functions/useful.vim
