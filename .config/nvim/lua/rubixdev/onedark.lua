local onedark = require('onedark')

onedark.setup {
    -- transparent = true,
    -- lualine = {
    --     transparent = true,
    -- },
    highlights = {
        -- Floats with cyan borders
        FloatBorder = { fg = '$cyan', bg = '$bg1' },
        LspInfoBorder = { fg = '$cyan', bg = '$bg1' },
        TelescopeBorder = { fg = '$cyan', bg = '$bg1' },
        TelescopePromptBorder = { fg = '$cyan', bg = '$bg1' },
        TelescopeResultsBorder = { fg = '$cyan', bg = '$bg1' },
        TelescopePreviewBorder = { fg = '$cyan', bg = '$bg1' },
        TelescopeNormal = { bg = '$bg1' },
    },
}
onedark.load()

return require('onedark.colors')
