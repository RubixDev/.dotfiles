scriptencoding utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
set clipboard+=unnamedplus " Use system clipboard
let mapleader = "\<Space>" " Space as leader key...
let maplocalleader = "\<Space>" " ...and as local leader key
set number relativenumber " Relative line numbers
set linebreak
set showbreak=↪
set nowrap " Do not wrap by default
autocmd FileType markdown set wrap " ...except in markdown files
set nofoldenable " Do not fold by default
set scrolloff=8 " Minimum lines to keep above and below cursor when scrolling
set noshowmode " Do not display current mode because we have a statusline plugin
set undofile " Preserve undo history when exiting vim
set signcolumn=yes " Always draw sign column. Prevent buffer moving when adding/deleting sign.
set nocompatible " Not compatible with VI
set mouse=a " Enable mouse support
set cmdheight=2 " Two lines for command output
set updatetime=300 " You will have bad experience for diagnostic messages when it's default 4000.
set colorcolumn=120 " Highlight column 120

" Tab settings
set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set shiftwidth=4    " number of spaces to use for autoindent
set expandtab       " expand tab to spaces so that tabs are spaces
set shiftround
autocmd FileType markdown setlocal ts=2 sts=2 sw=2
autocmd FileType toml setlocal ts=2 sts=2 sw=2
autocmd FileType make setlocal ts=4 sts=0 sw=4 noexpandtab

" Proper search
set incsearch
set ignorecase
set smartcase

" Completion
"" menu: Show a popup menu
"" menuone: Popup even when there's only one match
"" preview: Show extra information about the selected item
"" noinsert: Do not insert text until a selection is made
"" noselect: Do not select, force user to select one from the menu
set completeopt=menu,menuone,preview,noinsert,noselect

" Return to last edit position when opening files
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

" Set global is_android boolean
let g:is_android = executable('uname') && system('uname -o') == "Android\n"

" Highlight yanking
au TextYankPost * silent! lua vim.highlight.on_yank()

" Enable true-color support
if (has("termguicolors"))
    set termguicolors
endif
if exists('+termguicolors')
    let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
endif

" Load lua config
lua require('rubixdev')
