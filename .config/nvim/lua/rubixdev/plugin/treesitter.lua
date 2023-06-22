local treesitter = require('nvim-treesitter.configs')

vim.filetype.add { extension = { ebnf = 'ebnf', hms = 'homescript', rush = 'rush' } }

require('nvim-treesitter.parsers').get_parser_configs().hms = {
    install_info = {
        url = 'https://github.com/smarthome-go/tree-sitter-hms.git',
        files = { 'src/parser.c' },
        branch = 'main',
    },
    filetype = 'homescript',
}
require('nvim-treesitter.parsers').get_parser_configs().rush = {
    install_info = {
        url = 'https://github.com/rush-rs/tree-sitter-rush.git',
        files = { 'src/parser.c' },
        branch = 'main',
    },
}
require('nvim-treesitter.parsers').get_parser_configs().asm = {
    install_info = {
        url = 'https://github.com/rush-rs/tree-sitter-asm.git',
        files = { 'src/parser.c' },
        branch = 'main',
    },
}

treesitter.setup {
    ensure_installed = {
        'asm',
        'bash',
        'bibtex',
        'c',
        'comment',
        'cpp',
        'css',
        'diff',
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
            -- 'bash',
            'sxhkdrc',
        },
        additional_vim_regex_highlighting = false,
    },

    indent = {
        enable = true,
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
