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
syntax on 
set noruler
set rnu
set nowrap
set wildmenu
set cursorline
set nocp
set ignorecase
set encoding=utf-8
set scrolloff=5
set showcmd

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
ino <c-u> <esc>viwUviwA

" swich to the head or the end
nno <c-h> ^
nno <c-l> g_
" " <Backspace> in insert mode
" ino <c-o> <BS>
" cno <c-o> <BS>


       
"    mmm 
"  m"   "
"  #     
"  #     
"   'mmm'
"        
"<++>
aug C
autocmd!
au filetype c ino ; <ESC>A;
au filetype c ino ( ()<left>
au filetype c ino " ""<left>
au filetype c ino ' ''<left>
" au filetype c ino { <esc>o{}<left><CR><esc>O
au filetype c ino { <esc>A<space>{<CR>}<ESC>O
au filetype c ino ] {}<left>
au filetype c ino [ []<left>
au filetype c ino <buffer> # #<space><left><right>

au filetype c ino <F10> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

" au filetype c ino <cr> <esc>o
" au filetype c ino <c-h> <left>
" au filetype c ino <c-l> <right>
" au filetype c ino <c-j> <down>
" au filetype c ino <c-k> <up>
au filetype c ino <CR>  <ESC>o
au filetype c ino \\ /*    */<esc>4<left>a
" # au filetype c nno <leader>r :w!<CR>:!cc %<CR><CR>:ter<CR>
au filetype c nno <leader>r :w!<CR>:vert ter<CR>
au filetype c nno <F10> i0, 1, 2, 3, 4, 5, 6, 7, 8, 9<Esc>

" ABBREVIATION
au filetype c inorea  for for (<++>; <++>; <++>) {}<left><CR><esc>O<++><esc>/<++><CR>ca<

au filetype c ino if if ()<left>
au filetype c inorea fuck abcd




"  <tab> and <space> visualised
au filetype c setl list
au filetype c setl listchars=tab:>-,trail:-
au filetype c setl cindent
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
au filetype python ino <buffer> * <space>*<space><left><right>
" au filetype python ino <buffer> / <space>/<space><left><right>
au filetype python ino <buffer> % <space>%<space><left><right>
" au filetype python ino <buffer> = <space>=<space><left><right>
au filetype python ino <buffer> # #<space><left><right>
au filetype python ino <buffer> , ,<space><left><right>

" auto complete the () <> [] {}
" au filetype python ino <buffer> < <><left>
au filetype python ino <buffer> ( ()<left>
au filetype python ino <buffer> [ []<left>
au filetype python ino <buffer> { {}<left>
au filetype python ino <buffer> ' ''<left>
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

" to run the python script by type tr
au filetype python nn <buffer> <leader>r  :w<CR>:vertical term<CR><C-w>L


" Comment the line
au filetype python vn <buffer> <leader>c <C-v>0I# <esc>
au filetype python nn <buffer> <leader>c <C-v>0I# <esc>

au filetype python ono <buffer> ( :<C-u>normal!t)lvi(<cr>

au filetype python ia <buffer> if if:<left>
au filetype python ia <buffer> for for:<left>
au filetype python ia <buffer> else else:<left>
au filetype python ia <buffer> while while:<left>
au filetype python ia <buffer> def def:<left>
au filetype python ia <buffer> class class:<left>
au filetype python ia <buffer> ret return
au filetype python ia <buffer> @@ 1398881912@qq.com
au filetype python ia <buffer> pirnt print


"  <tab> and <space> visualised
au filetype python set list
au filetype python set listchars=tab:>-,trail:-
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

" ┌──────────────────────────────────────────┐
" │                                          │
" │ mm   m                             ""#   │
" │ #"m  #  mmm    m mm  mmmmm   mmm     #   │
" │ # #m # #" "#   #"  " # # #  "   #    #   │
" │ #  # # #   #   #     # # #  m"""#    #   │
" │ #   ## "#m#"   #     # # #  "mm"#    "mm │
" │                                          │
" │                                          │
" └──────────────────────────────────────────┘
" <++>
aug normal
autocmd!
""autocmd StdinReadPre * let s:std_in=1
" au BufWinEnter * if argc() == 0 && !exists('s:std_in') |tt|endif

" " number in front of lines
au BufWinEnter * ino <c-@> <Nop>

" replace  { [
au BufWinEnter * nn [ {
au BufWinEnter * nn ] }

" fold method
au BufWinEnter * nn s <Nop>
au BufWinEnter * nn ff za
au BufWinEnter * nn fk zm
au BufWinEnter * nn fj zr

" edit $myvimrc
au BufWinEnter * nn <leader>ev :vsplit $MYVIMRC<CR>
au BufWinEnter * nm <leader>sv :w<CR>:source $MYVIMRC<CR>\|\|

" tab site
au BufWinEnter * nn TT :tabnew<CR>
au BufWinEnter * nn th :-tabnext<CR>
au BufWinEnter * nn tl :+tabnext<CR>

" screen create
au BufWinEnter * nn <c-s><c-h> :set nosplitright<CR>:vsplit<CR>
au BufWinEnter * nn <c-s><c-l> :set splitright<CR>:vsplit<CR>
au BufWinEnter * nn <c-s><c-k> :set splitright<CR>:split<CR>
au BufWinEnter * nn <c-s><c-j> :set nosplitright<CR>:split<CR>

" screen switch
au BufWinEnter * nn wk <c-w>k
au BufWinEnter * nn wj <c-w>j
au BufWinEnter * nn wh <c-w>h
au BufWinEnter * nn wl <c-w>l

" screen switch
au BufWinEnter * nn <s-K> <c-w>K
au BufWinEnter * nn <s-J> <c-w>J
au BufWinEnter * nn <s-H> <c-w>H
au BufWinEnter * nn <s-L> <c-w>L

" screen size
au BufWinEnter * nn _ :resize -10<CR>
au BufWinEnter * nn + :resize +10<CR>
au BufWinEnter * nn - :vertical resize -15<CR>
au BufWinEnter * nn = :vertical resize +15<CR>

"cmap 1 !
au BufWinEnter * nn w <c-w>
" au BufWinEnter * nn 7 5j
" au BufWinEnter * nn 8 5k

" terminal
au BufWinEnter * nn <leader>r :w<CR>:vert terminal<CR><c-w>L

" save the file in the buffer 
au BufWinEnter * nn S :w<CR>

" shortcuts
au BufWinEnter * ino jk <esc>
au BufWinEnter * ino <c-f> <right>
au BufWinEnter * ino <c-b> <left>
au BufWinEnter * ino <c-a> <Esc>^i
au BufWinEnter * ino <c-e> <Esc>g_a

" Turn the ; into <CR> 
" au BufWinEnter * cno ; <CR>
" au BufWinEnter * nn  ; <CR>
" au BufWinEnter * ino ; <esc>o

" spell check
au BufWinEnter * nn  sc :setl spell!<CR>
au BufWinEnter * ino <s-s><s-c> <c-x>s

" shortcuts switched
au BufWinEnter * nn  <space> :

" move easily by <c-h><c-l>
au BufWinEnter * cno <c-a> 100<left>
au BufWinEnter * cno <c-f> <right>
au BufWinEnter * cno <c-b> <left>

" Anchor Point
au BufWinEnter * ino <leader>f <esc>/<++><CR>ca<
au BufWinEnter * nn  <leader>f /<++><CR>

au BufWinEnter * nn <leader>t :set termguicolors!<CR>

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
setl nocp
aug md 
autocmd!
au filetype markdown nnoremap <C-p> <Plug>MarkdownPreviewToggle
aug end
