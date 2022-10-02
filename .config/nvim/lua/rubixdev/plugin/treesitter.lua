local treesitter = require('nvim-treesitter.configs')

vim.filetype.add { extension = { ebnf = 'ebnf' } }

require('nvim-treesitter.parsers').get_parser_configs().ebnf = {
    install_info = {
        url = 'https://github.com/RubixDev/ebnf.git',
        files = { 'crates/tree-sitter-ebnf/src/parser.c' },
        branch = 'main',
    },
}

treesitter.setup {
    ensure_installed = {
        'bash',
        'bibtex',
        'c',
        'comment',
        'cpp',
        'css',
        'dockerfile',
        'ebnf',
        'gdscript',
        -- 'gitattributes', -- currently experimental
        'gitignore',
        'go',
        'godot_resource',
        'gomod',
        'html',
        'java',
        'javascript',
        'jsdoc',
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
