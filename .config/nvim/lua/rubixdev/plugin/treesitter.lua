local treesitter = require('nvim-treesitter.configs')

treesitter.setup {
    ensure_installed = {
        'bash',
        'bibtex',
        'c',
        'cpp',
        'css',
        'dockerfile',
        'gdscript',
        -- 'gitattributes', -- currently experimental
        'gitignore',
        'go',
        'godot_resource',
        'gomod',
        'html',
        'java',
        'javascript',
        'json',
        'json5',
        'jsonc',
        'kotlin',
        'latex',
        'lua',
        'make',
        'markdown', -- currently experimental
        'markdown_inline', -- currently experimental
        'python',
        'rust',
        'scss',
        'svelte',
        'sxhkdrc',
        'toml',
        'typescript',
        'vim',
        'yaml',
    },
    sync_install = false,
    auto_install = true,

    highlight = {
        enable = true,
        disable = {
            'bash',
            'sxhkdrc',
        },
        additional_vim_regex_highlighting = false,
    },

    -- RRethy/nvim-treesitter-endwise
    endwise = {
        enable = true,
    },

    -- windwp/nvim-ts-autotag
    autotag = {
        enable = true,
    },

    -- andymass/vim-matchup
    matchup = {
        enable = true,
    },

    -- p00f/nvim-ts-rainbow
    rainbow = {
        enable = true,
        extended_mode = false,
    },
}
