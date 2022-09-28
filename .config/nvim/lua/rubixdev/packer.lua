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
    autocmd BufWritePost packer.lua source <afile> | PackerSync
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
        use {
            {
                'windwp/nvim-autopairs',
                config = function() require('rubixdev.plugin.autopairs') end,
            },
            { 'RRethy/nvim-treesitter-endwise' },
            { 'windwp/nvim-ts-autotag' },
        }
        use { 'tpope/vim-abolish' }
        use {
            'numToStr/Comment.nvim',
            config = function() require('Comment').setup() end,
        }
        use { 'airblade/vim-rooter' }
        use { 'dstein64/vim-startuptime' }
        use {
            'lewis6991/impatient.nvim',
            config = function() require('impatient') end,
        }
        use { 'tpope/vim-repeat' }
        use {
            'ur4ltz/surround.nvim',
            config = function() require('rubixdev.plugin.surround') end,
        }

        -- GUI enhancements
        use {
            'nvim-lualine/lualine.nvim',
            requires = { 'kyazdani42/nvim-web-devicons' },
            config = function() require('rubixdev.plugin.lualine') end,
        }
        use {
            'lukas-reineke/indent-blankline.nvim',
            config = function() require('rubixdev.plugin.indent_blankline') end,
        }

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
            config = function() require('rubixdev.plugin.telescope') end,
        }

        -- Language support
        use { 'fatih/vim-go', run = ':GoUpdateBinaries', disable = _G.is_android }
        use {
            'preservim/vim-markdown',
            requires = { 'godlygeek/tabular' },
            config = function() require('rubixdev.plugin.markdown') end,
        }
        use { 'averms/ebnf-vim' }
        use { 'baskerville/vim-sxhkdrc' }
        use {
            'saecki/crates.nvim',
            requires = { 'nvim-lua/plenary.nvim' },
        }

        -- Treesitter
        use {
            'nvim-treesitter/nvim-treesitter',
            run = function() require('nvim-treesitter.install').update { with_sync = true } end,
            config = function() require('rubixdev.plugin.treesitter') end,
        }
        use { 'nvim-treesitter/nvim-treesitter-context' }
        use { 'p00f/nvim-ts-rainbow' }
        use { 'nvim-treesitter/playground' }

        -- LSP setup
        use {
            'neovim/nvim-lspconfig',
            config = function() require('rubixdev.lsp') end,
        }
        use {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'jayp0521/mason-null-ls.nvim',
            'RubixDev/mason-update-all',
        }
        use { 'ray-x/lsp_signature.nvim' }
        use { 'habamax/vim-godot', disable = _G.is_android }
        use {
            'jose-elias-alvarez/null-ls.nvim',
            requires = {
                'nvim-lua/plenary.nvim',
            },
        }
        use {
            'rmagatti/goto-preview',
            config = function() require('rubixdev.plugin.goto_preview') end,
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
            config = function() require('rubixdev.plugin.cmp') end,
        }

        -- Snippets
        use {
            'L3MON4D3/LuaSnip',
            requires = {
                'rafamadriz/friendly-snippets',
            },
        }

        -- Discord presence
        use { 'andweeb/presence.nvim', disable = _G.is_android }

        -- Git
        use { 'tpope/vim-fugitive' }
        use {
            'lewis6991/gitsigns.nvim',
            config = function() require('rubixdev.plugin.gitsigns') end,
        }

        -- Markdown preview
        use { 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', disable = _G.is_android }

        -- Automatically set up your configuration after cloning packer.nvim
        if packer_bootstrap then require('packer').sync() end
    end,
    config = {
        display = {
            open_fn = function() return require('packer.util').float { border = 'rounded' } end,
            prompt_border = 'rounded',
        },
        autoremove = true,
    },
}
