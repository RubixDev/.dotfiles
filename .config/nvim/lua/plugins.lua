local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

return require('packer').startup(function(use)
    -- Packer
    use 'wbthomason/packer.nvim'

    -- Theme
    use 'rakr/vim-one'

    -- VIM enhancements
    use 'editorconfig/editorconfig-vim'
    use 'andymass/vim-matchup'
    use 'jiangmiao/auto-pairs'
    use 'tpope/vim-abolish'
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }

    -- GUI enhancements
    use 'vim-airline/vim-airline'
    use 'vim-airline/vim-airline-themes'
    use 'kyazdani42/nvim-web-devicons'
    use 'lukas-reineke/indent-blankline.nvim'
    use {
        'wellle/context.vim',
        config = function()
            vim.g.context_add_mappings = false
            vim.g.context_highlight_border = '<hide>'
            vim.g.context_highlight_normal = 'PMenu'
        end,
    }

    -- Fuzzy Finder
    use 'airblade/vim-rooter'
    use { 'junegunn/fzf', run = function() vim.fn['fzf#install'](0) end }
    use 'junegunn/fzf.vim'

    -- Language support
    use 'cespare/vim-toml'
    use 'stephpy/vim-yaml'
    use 'rust-lang/rust.vim'
    use { 'fatih/vim-go', run = ':GoUpdateBinaries' }
    use 'godlygeek/tabular'
    use 'preservim/vim-markdown'
    use 'pangloss/vim-javascript'
    use 'HerringtonDarkholme/yats.vim'
    use 'Shougo/context_filetype.vim'
    use 'sheerun/vim-polyglot'
    use 'evanleck/vim-svelte'
    use 'averms/ebnf-vim'
    use 'frabjous/knap'

    -- LSP setup
    use 'neovim/nvim-lspconfig'
    use 'williamboman/nvim-lsp-installer'
    use 'nvim-lua/lsp_extensions.nvim'
    use 'ray-x/lsp_signature.nvim'
    use 'habamax/vim-godot'
    use 'nvim-lua/plenary.nvim'
    use 'jose-elias-alvarez/null-ls.nvim'
    use 'MunifTanjim/prettier.nvim'

    -- Completion
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use { 'hrsh7th/nvim-cmp', config = function()
        local cmp = require 'cmp'
        cmp.setup({
            snippet = {
                expand = function(args)
                    vim.fn["vsnip#anonymous"](args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                -- Tab immediately completes. C-n/C-p to select.
                ['<Tab>'] = cmp.mapping.confirm({ select = true }),
                -- Ctrl+Space to show completions
                ['<C-Space>'] = cmp.mapping.complete(),
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
    end }

    -- Discord presence
    use 'andweeb/presence.nvim'

    -- Only because nvim-cmp _requires_ snippets
    use 'hrsh7th/cmp-vsnip'
    use 'hrsh7th/vim-vsnip'

    -- Git
    use 'tpope/vim-fugitive'
    use 'airblade/vim-gitgutter'

    -- Markdown preview
    use { 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install' }

    -- Automatically set up your configuration after cloning packer.nvim
    if packer_bootstrap then
        require('packer').sync()
    end
end)
