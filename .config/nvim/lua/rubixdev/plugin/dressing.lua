require('dressing').setup {
    input = {
        enabled = true,
        default_prompt = 'Input:',
        title_pos = 'left',
        insert_only = false,
        start_in_insert = true,

        -- These are passed to nvim_open_win
        anchor = 'SW',
        border = 'rounded',
        relative = 'cursor',

        -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        prefer_width = 40,
        width = nil,
        -- min_width and max_width can be a list of mixed types.
        -- min_width = {20, 0.2} means 'the greater of 20 columns or 20% of total'
        max_width = { 140, 0.9 },
        min_width = { 20, 0.2 },

        buf_options = {},
        win_options = {
            winblend = 10,     -- Window transparency (0-100)
            wrap = false,      -- Disable line wrapping
            list = true,       -- Indicator for when text exceeds window
            listchars = 'precedes:…,extends:…',
            sidescrolloff = 0, -- Increase this for more context when text scrolls off the window
        },

        mappings = {
            n = {
                ['<Esc>'] = 'Close',
                ['<C-k>'] = 'Close',
                ['<CR>'] = 'Confirm',
                ['<C-p>'] = 'HistoryPrev',
                ['<C-n>'] = 'HistoryNext',
            },
            i = {
                ['<C-c>'] = 'Close',
                ['<CR>'] = 'Confirm',
                ['<Up>'] = 'HistoryPrev',
                ['<Down>'] = 'HistoryNext',
            },
        },
    },
    select = {
        enabled = true,
        backend = { 'telescope', 'fzf', 'builtin', 'fzf_lua', 'nui' },
        trim_prompt = true, -- Trim trailing `:` from prompt

        -- Options for telescope selector
        -- These are passed into the telescope picker directly. Can be used like:
        -- telescope = require('telescope.themes').get_ivy({...})
        telescope = nil,

        -- Options for fzf selector
        fzf = {
            window = {
                width = 0.5,
                height = 0.4,
            },
        },

        -- Options for built-in selector
        builtin = {
            anchor = 'NW',
            border = 'rounded',
            relative = 'editor',

            buf_options = {},
            win_options = {
                winblend = 10, -- Window transparency (0-100)
                cursorline = true,
                cursorlineopt = 'both',
            },

            -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            -- the min_ and max_ options can be a list of mixed types.
            -- max_width = {140, 0.8} means 'the lesser of 140 columns or 80% of total'
            width = nil,
            max_width = { 140, 0.8 },
            min_width = { 40, 0.2 },
            height = nil,
            max_height = 0.9,
            min_height = { 10, 0.2 },

            -- Set to `false` to disable
            mappings = {
                ['<Esc>'] = 'Close',
                ['<C-c>'] = 'Close',
                ['<CR>'] = 'Confirm',
            },
        },
    },
}
