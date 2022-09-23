local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path }
        vim.cmd([[packadd packer.nvim]])
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

return require('packer').startup {
    function(use)
        -- Packer
        use { 'wbthomason/packer.nvim' }

        -- Theme
        use { 'navarasu/onedark.nvim' }

        -- VIM enhancements
        use { 'editorconfig/editorconfig-vim' }
        use { 'andymass/vim-matchup' }
        use { 'jiangmiao/auto-pairs' }
        use { 'tpope/vim-abolish' }
        use {
            'numToStr/Comment.nvim',
            config = function()
                require('Comment').setup()
            end,
        }
        use { 'airblade/vim-rooter' }
        use { 'dstein64/vim-startuptime' }
        use { 'lewis6991/impatient.nvim' }

        -- GUI enhancements
        use {
            'nvim-lualine/lualine.nvim',
            requires = { 'kyazdani42/nvim-web-devicons' },
        }
        use { 'lukas-reineke/indent-blankline.nvim' }

        -- Fuzzy Finder
        use {
            'nvim-telescope/telescope-fzf-native.nvim',
            run = 'make',
        }

        -- Telescope
        use {
            'nvim-telescope/telescope.nvim',
            branch = '0.1.x',
            requires = {
                'nvim-lua/plenary.nvim',
            },
        }

        -- Language support
        use { 'fatih/vim-go', run = ':GoUpdateBinaries', disable = vim.g.is_android == 1 }
        use {
            'preservim/vim-markdown',
            requires = { 'godlygeek/tabular' },
        }
        use { 'averms/ebnf-vim' }
        use { 'baskerville/vim-sxhkdrc' }

        -- Treesitter
        use {
            'nvim-treesitter/nvim-treesitter',
            run = function()
                require('nvim-treesitter.install').update { with_sync = true }
            end,
        }
        use { 'nvim-treesitter/nvim-treesitter-context' }

        -- LSP setup
        use { 'neovim/nvim-lspconfig' }
        use {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'jayp0521/mason-null-ls.nvim',
            'RubixDev/mason-update-all',
        }
        use { 'ray-x/lsp_signature.nvim' }
        use { 'habamax/vim-godot', disable = vim.g.is_android == 1 }
        use {
            'jose-elias-alvarez/null-ls.nvim',
            requires = {
                'nvim-lua/plenary.nvim',
            },
        }

        -- Completion
        use {
            'hrsh7th/nvim-cmp',
            requires = {
                'hrsh7th/cmp-nvim-lsp',
                'hrsh7th/cmp-nvim-lua',
                'hrsh7th/cmp-path',
                'hrsh7th/cmp-cmdline',
                'hrsh7th/cmp-buffer',
                'saadparwaiz1/cmp_luasnip',
            },
        }

        -- Snippets
        use {
            'L3MON4D3/LuaSnip',
            requires = {
                'rafamadriz/friendly-snippets',
            },
        }

        -- Discord presence
        use { 'andweeb/presence.nvim', disable = vim.g.is_android == 1 }

        -- Git
        use { 'tpope/vim-fugitive' }
        use { 'lewis6991/gitsigns.nvim' }

        -- Markdown preview
        use { 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', disable = vim.g.is_android == 1 }

        -- Automatically set up your configuration after cloning packer.nvim
        if packer_bootstrap then
            require('packer').sync()
        end
    end,
    config = {
        display = {
            open_fn = function()
                return require('packer.util').float { border = 'rounded' }
            end,
            prompt_border = 'rounded',
        },
        autoremove = true,
    },
}
