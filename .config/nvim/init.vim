scriptencoding utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
set clipboard+=unnamedplus " Use system clipboard
let mapleader = "\<Space>"
set number relativenumber
set linebreak
set showbreak=↪
set nowrap
set nofoldenable
set scrolloff=8 " Minimum lines to keep above and below cursor when scrolling
set noshowmode " Do not display current mode because we have airline
set undofile " Preserve undo history when exiting vim
set signcolumn=yes " Always draw sign column. Prevent buffer moving when adding/deleting sign.
set nocompatible " Required for polyglot
set mouse=a
" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

let g:is_android = executable('uname') && system('uname -o') == "Android\n"

" Plugins
call plug#begin()

" Theme
Plug 'rakr/vim-one'

" VIM enhancements
Plug 'editorconfig/editorconfig-vim'
Plug 'max397574/better-escape.nvim'
Plug 'andymass/vim-matchup'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-abolish'

" GUI enhancements
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'wellle/context.vim'

" Fuzzy Finder
Plug 'airblade/vim-rooter'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Language support
Plug 'cespare/vim-toml'
Plug 'stephpy/vim-yaml'
Plug 'rust-lang/rust.vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'
Plug 'pangloss/vim-javascript'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'Shougo/context_filetype.vim'
Plug 'sheerun/vim-polyglot'
Plug 'evanleck/vim-svelte'
Plug 'averms/ebnf-vim'
Plug 'frabjous/knap'

" LSP setup
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
Plug 'nvim-lua/lsp_extensions.nvim'
Plug 'ray-x/lsp_signature.nvim'
Plug 'habamax/vim-godot'
Plug 'nvim-lua/plenary.nvim'
Plug 'jose-elias-alvarez/null-ls.nvim'
Plug 'MunifTanjim/prettier.nvim'

" Completion
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" Discord presence
Plug 'andweeb/presence.nvim'

" Only because nvim-cmp _requires_ snippets
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Markdown preview
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }

call plug#end()

" Automatically install missing plugins
autocmd VimEnter *
    \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \|   PlugInstall --sync | q
    \| endif

" Theming
syntax on
colorscheme one
set background=dark
let g:one_allow_italics = 1
au TextYankPost * silent! lua vim.highlight.on_yank()

let g:airline_theme='one'
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_skip_emtpy_sections = 1
let g:airline_detect_spell = 0

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ' '
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.colnr = ' :'
let g:airline_symbols.dirty = ' ⚡'

" The following two functions are taken from SpaceVim
function! s:isDarwin() abort
    if exists('s:is_darwin')
        return s:is_darwin
    endif
    if has('macunix')
        let s:is_darwin = 1
        return s:is_darwin
    endif
    if ! has('unix')
        let s:is_darwin = 0
        return s:is_darwin
    endif
    let s:is_darwin = system('uname -s') ==# "Darwin\n"
    return s:is_darwin
endfunction
function! Fileformat() abort
    let fileformat = ''
    if &fileformat ==? 'dos'
        let fileformat = ''
    elseif &fileformat ==? 'unix'
        if s:isDarwin()
            let fileformat = ''
        else
            let fileformat = ''
        endif
    elseif &fileformat ==? 'mac'
        let fileformat = ''
    endif
    return fileformat
endfunction
function! AirlineInit()
    let g:airline_section_b = airline#section#create_left(['branch'])
    let g:airline_section_y = airline#section#create_right(['fileencoding', 'bom', 'eol'])
    let g:airline_section_y = " %{&fenc . ' ' . Fileformat()} "
endfunction
autocmd User AirlineAfterInit call AirlineInit()

" Enable true-color support
if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif
if (has("termguicolors"))
    set termguicolors
endif
if exists('+termguicolors')
    let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
endif

" General tab settings
set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set shiftwidth=4    " number of spaces to use for autoindent
set expandtab       " expand tab to spaces so that tabs are spaces
set shiftround
autocmd FileType markdown setlocal ts=2 sts=2 sw=2
autocmd FileType toml setlocal ts=2 sts=2 sw=2
autocmd FileType json setlocal ts=2 sts=2 sw=2
autocmd FileType make setlocal ts=4 sts=0 sw=4 noexpandtab

" Proper search
set incsearch
set ignorecase
set smartcase

" Replace all with S
nnoremap S :%s//g<left><left>

" Search results centered please
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz

" Ctrl+h to stop searching
vnoremap <C-h> :nohlsearch<cr>
nnoremap <C-h> :nohlsearch<cr>

" Ctrl+k as Esc
nnoremap <C-k> <Esc>
inoremap <C-k> <Esc>
vnoremap <C-k> <Esc>
snoremap <C-k> <Esc>
xnoremap <C-k> <Esc>
cnoremap <C-k> <C-c>
onoremap <C-k> <Esc>
lnoremap <C-k> <Esc>
tnoremap <C-k> <Esc>

" Jump to start and end of line using the home row keys
map H ^
map L $

" ; as : for commands
nnoremap ; :

" No arrow keys --- force yourself to use the home row
nnoremap <up> <nop>
nnoremap <down> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" Left and right can switch buffers
nnoremap <left> :bp<CR>
nnoremap <right> :bn<CR>

" <leader><leader> toggles between buffers
nnoremap <leader><leader> <c-^>

" Open hotkeys
map <leader>o :Files<CR>
nmap <leader>; :Buffers<CR>

" Quick save and quit
nmap <leader>w :w<CR>
nmap <leader>q :q<CR>

" Run Makefile
noremap <leader>m :!make<space>
noremap <leader>M :!make<CR>

" Keymap for replacing up to next _ or -
noremap <leader>m ct_

" Delete, not cut
nnoremap <leader>d "_d
nnoremap <leader>c "_c
nnoremap <leader>x "_x
nnoremap <leader>D "_D
nnoremap <leader>C "_C

" Git
nmap <leader>ga :Git add -p<CR>
nmap <leader>gc :Git commit -v<CR>
nmap <leader>gp :Git push<CR>
nmap <leader>gl :Git pull<CR>

" Markdown
map <Leader>mp :MarkdownPreview<CR>
map <Leader>mP :MarkdownPreviewStop<CR>
map <Leader>mf :TableFormat<CR>
nmap <Leader>mw :set invwrap<CR>
" Keybind to set markdown language to german
nmap <Leader>ml :call append(line('0'), ['---', 'lang: de-DE', '---', ''])<CR>
" Map o to A<CR> in markdown
autocmd FileType markdown nmap <buffer> o A<CR>
" Default to wrapping
autocmd FileType markdown set wrap

" Insert line above/below cursor without insert mode
map <Leader>N :<C-U>call append(line(".")-1, repeat([''], v:count1))<CR>
map <Leader>n :<C-U>call append(line("."), repeat([''], v:count1))<CR>

" Completion
" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect
set cmdheight=2 " Better display for messages
set updatetime=300 " You will have bad experience for diagnostic messages when it's default 4000.

" ripgrep
if executable('rg')
    set grepprg=rg\ --no-heading\ --vimgrep
    set grepformat=%f:%l:%c:%m
endif
noremap <leader>s :Rg<space>
let g:fzf_layout = { 'down': '~20%' }
command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \   'rg --column --line-number --no-heading --color=always -. -g "!.git" '.shellescape(<q-args>), 1,
    \   <bang>0 ? fzf#vim#with_preview('up:60%')
    \           : fzf#vim#with_preview('right:50%:hidden', '?'),
    \   <bang>0)

function! s:list_cmd()
    let base = fnamemodify(expand('%'), ':h:.:S')
    let fd = 'fd -tf -LHE .git -E "*.png" -E "*.jpg" -E "*.jpeg" -E "*.gif" -E "*.xcf" -E "*.zip" -E "*.ttf" -E "*.import" -E node_modules'
    return base == '.' ? fd : printf('%s | proximity-sort %s', fd, shellescape(expand('%')))
endfunction

command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, {'source': s:list_cmd(),
    \                               'options': '--tiebreak=index'}, <bang>0)

" Svelte js/ts and css detection
if !exists('g:context_filetype#same_filetypes')
    let g:context_filetype#filetypes = {}
endif

let g:context_filetype#filetypes.svelte =
\ [
\   {'filetype' : 'javascript', 'start' : '<script>', 'end' : '</script>'},
\   {
\     'filetype': 'typescript',
\     'start': '<script\%( [^>]*\)\? \%(ts\|lang="\%(ts\|typescript\)"\)\%( [^>]*\)\?>',
\     'end': '',
\   },
\   {'filetype' : 'css', 'start' : '<style \?.*>', 'end' : '</style>'},
\ ]

let g:ft = ''

" Svelte ts and scss syntax highlighting
let g:svelte_preprocessor_tags = [
\ { 'name': 'ts', 'tag': 'script', 'as': 'typescript' }
\ ]
let g:svelte_preprocessors = ['ts', 'scss']

" Enable type inlay hints in rust
autocmd CursorHold,CursorHoldI *.rs :lua require'lsp_extensions'.inlay_hints{ only_current_line = true }

"""""""""
" LaTeX "
"""""""""
" F5 processes the document once, and refreshes the view "
inoremap <silent> <F5> <C-o>:lua require("knap").process_once()<CR>
vnoremap <silent> <F5> <C-c>:lua require("knap").process_once()<CR>
nnoremap <silent> <F5> :lua require("knap").process_once()<CR>

" F6 closes the viewer application, and allows settings to be reset "
inoremap <silent> <F6> <C-o>:lua require("knap").close_viewer()<CR>
vnoremap <silent> <F6> <C-c>:lua require("knap").close_viewer()<CR>
nnoremap <silent> <F6> :lua require("knap").close_viewer()<CR>

" F7 toggles the auto-processing on and off "
inoremap <silent> <F7> <C-o>:lua require("knap").toggle_autopreviewing()<CR>
vnoremap <silent> <F7> <C-c>:lua require("knap").toggle_autopreviewing()<CR>
nnoremap <silent> <F7> :lua require("knap").toggle_autopreviewing()<CR>

" F8 invokes a SyncTeX forward search, or similar, where appropriate "
inoremap <silent> <F8> <C-o>:lua require("knap").forward_jump()<CR>
vnoremap <silent> <F8> <C-c>:lua require("knap").forward_jump()<CR>
nnoremap <silent> <F8> :lua require("knap").forward_jump()<CR>

" Disable autosave
let g:knap_settings = {
    \ "textopdf": "lualatex -jobname \"$(basename -s .pdf %outputfile%)\" -halt-on-error",
    \ "textopdfbufferasstdin": v:true
\ }

lua << END

-- Completion
local cmp = require'cmp'
cmp.setup({
    snippet = {
        -- REQUIRED by nvim-cmp. get rid of it once we can
        expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        -- Tab immediately completes. C-n/C-p to select.
        ['<Tab>'] = cmp.mapping.confirm({ select = true })
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
    }, {
        { name = 'path' },
    }),
    experimental = {
        ghost_text = true,
    },
})

-- Enable completing paths in :
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' },
    }, {
        { name = 'cmdline' },
    })
})

-- LSP setup
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    --Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { noremap=true, silent=true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<space>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<space>Q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
    buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

    -- Get signatures (and _only_ signatures) when in argument lists.
    require "lsp_signature".on_attach({
        doc_lines = 0,
        handler_opts = {
        border = "none"
        },
    })
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
require('nvim-lsp-installer').setup { on_attach = on_attach, automatic_installation = true, capabilities = capabilities }
require('lspconfig').rust_analyzer.setup { on_attach = on_attach, capabilities = capabilities }
require('lspconfig').vimls.setup { on_attach = on_attach, capabilities = capabilities }
require('lspconfig').bashls.setup { on_attach = on_attach, capabilities = capabilities }
require('lspconfig').dockerls.setup { on_attach = on_attach, capabilities = capabilities }
require('lspconfig').golangci_lint_ls.setup { on_attach = on_attach, capabilities = capabilities }
require('lspconfig').gopls.setup { on_attach = on_attach, capabilities = capabilities }
require('lspconfig').sumneko_lua.setup { on_attach = on_attach, capabilities = capabilities }
require('lspconfig').pylsp.setup { on_attach = on_attach, capabilities = capabilities }
if vim.g.is_android == 0 then
    require('lspconfig').jdtls.setup { on_attach = on_attach, capabilities = capabilities }
    require('lspconfig').kotlin_language_server.setup { on_attach = on_attach, capabilities = capabilities }
    require('lspconfig').gdscript.setup { on_attach = on_attach, capabilities = capabilities }
    require('lspconfig').clangd.setup { on_attach = on_attach, capabilities = capabilities }
    require('lspconfig').taplo.setup { on_attach = on_attach, capabilities = capabilities }
    require('lspconfig').ltex.setup { on_attach = on_attach, capabilities = capabilities } -- or texlab
    require('lspconfig').svelte.setup { on_attach = on_attach, capabilities = capabilities }
    require('lspconfig').tsserver.setup { on_attach = on_attach, capabilities = capabilities }
    require('lspconfig').cssls.setup { on_attach = on_attach, capabilities = capabilities }
    require('lspconfig').html.setup { on_attach = on_attach, capabilities = capabilities }
    require('lspconfig').emmet_ls.setup { on_attach = on_attach, capabilities = capabilities }
    require('lspconfig').jsonls.setup { on_attach = on_attach, capabilities = capabilities }
    require('null-ls').setup({ on_attach = on_attach, capabilities = capabilities })
    require('prettier').setup({
        bin = 'prettier',
        filetypes = {
            "css",
            "scss",
            "html",
            "javascript",
            "typescript",
            "json",
            "json5",
            "svelte",
        },

        arrow_parens = "avoid",
        semi = false,
        single_quote = true,
        tab_width = 4,
        trailing_comma = "all",
    })
end
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = true,
        signs = true,
        update_in_insert = true,
    }
)

-- Better escape
require("better_escape").setup {
    mapping = {"jk", "jj"},
    timeout = vim.o.timeoutlen,
    clear_empty_lines = true,
    keys = function()
      return vim.api.nvim_win_get_cursor(0)[2] > 1 and '<esc>l' or '<esc>'
    end,
}

END
