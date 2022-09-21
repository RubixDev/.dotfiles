local status_ok, telescope = pcall(require, 'telescope')
if not status_ok then
    return
end

local actions = require('telescope.actions')

-- Extensions
telescope.load_extension('fzf')

-- Include hidden files except '.git'
local vimgrep_arguments = { unpack(require('telescope.config').values.vimgrep_arguments) }
table.insert(vimgrep_arguments, "--hidden")
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!.git/*")

-- Setup
telescope.setup {
    defaults = {
        vimgrep_arguments = vimgrep_arguments,
        mappings = {
            i = {
                -- I don't need normal mode
                ['<C-k>'] = actions.close,
                ['<Esc>'] = actions.close,

                -- Next/previous item with Ctrl+N and Ctrl+P
                ['<C-n>'] = actions.move_selection_next,
                ['<C-p>'] = actions.move_selection_previous,

                -- Scroll preview up and down with Ctrl+U and Ctrl+D
                ['<C-u>'] = actions.preview_scrolling_up,
                ['<C-d>'] = actions.preview_scrolling_down,

                -- Select with Enter
                ['<CR>'] = actions.select_default,
            },
            n = {},
        },
    },
    pickers = {
        find_files = {
            -- Include hidden files except '.git'
            hidden = true,
            find_command = { 'rg', '--files', '--color', 'never', '--glob', '!.git/*' },
        },
    },
    extensions = {
        fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = 'smart_case', -- or 'ignore_case' or 'respect_case'
        },
    }
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<Leader>o', builtin.find_files)
vim.keymap.set('n', '<Leader>O', function() builtin.find_files { no_ignore = true } end)
vim.keymap.set('n', '<Leader>s', builtin.live_grep)
vim.keymap.set('n', '<Leader>;', builtin.buffers)
