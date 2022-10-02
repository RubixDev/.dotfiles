local onedark = require('onedark')

onedark.setup {
    -- transparent = true,
    -- lualine = {
    --     transparent = true,
    -- },
    highlights = {
        -- Floats with cyan borders and solid background
        FloatBorder = { fg = '$cyan', bg = '$bg1' },
        LspInfoBorder = { fg = '$cyan', bg = '$bg1' },
        TelescopeBorder = { fg = '$cyan', bg = '$bg1' },
        TelescopePromptBorder = { fg = '$cyan', bg = '$bg1' },
        TelescopeResultsBorder = { fg = '$cyan', bg = '$bg1' },
        TelescopePreviewBorder = { fg = '$cyan', bg = '$bg1' },
        TelescopeNormal = { bg = '$bg1' },

        -- Correctly looking pills in crates.nvim popup
        CratesNvimPopupPillText = { fg = '$bg0', bg = '$fg' },
        CratesNvimPopupPillBorder = { fg = '$fg' },

        -- TODO comment highlighting
        Todo = { fg = '$orange', fmt = 'bold' },
        TSTodo = { fg = '$orange', fmt = 'bold' },
        TSWarning = { fg = '$orange', fmt = 'bold' },
    },
}
onedark.load()

vim.api.nvim_set_hl(0, '@grammar.terminal', { link = '@string' })
vim.api.nvim_set_hl(0, '@grammar.special', { link = '@string.regex' })
vim.api.nvim_set_hl(0, '@grammar.nonterminal.pascal', { link = '@type' })
vim.api.nvim_set_hl(0, '@grammar.nonterminal.camel', { link = '@property' })
vim.api.nvim_set_hl(0, '@grammar.nonterminal.upper', { link = '@constant' })
vim.api.nvim_set_hl(0, '@grammar.nonterminal.lower', { link = '@parameter' })

return require('onedark.colors')
