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
        ['@text.todo'] = { fg = '$orange', fmt = 'bold' },

        -- Rust
        ['@storageclass.lifetime'] = { fg = '$red' },
        ['@type.qualifier'] = { fg = '$purple' },

        -- Tree-sitter diff highlights
        ['@text.diff.add'] = { fg = '$green' },
        ['@text.diff.delete'] = { fg = '$red' },
    },
}
onedark.load()

vim.api.nvim_set_hl(0, '@string.special.grammar', { link = '@string.regex' })
vim.api.nvim_set_hl(0, '@symbol.grammar.pascal', { link = '@type' })
vim.api.nvim_set_hl(0, '@symbol.grammar.camel', { link = '@property' })
vim.api.nvim_set_hl(0, '@symbol.grammar.upper', { link = '@constant' })
vim.api.nvim_set_hl(0, '@symbol.grammar.lower', { link = '@parameter' })

return require('onedark.colors')
