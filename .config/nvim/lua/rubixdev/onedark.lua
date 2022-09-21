local onedark = require('onedark')

onedark.setup {
    -- transparent = true,
    -- lualine = {
    --     transparent = true,
    -- },
    highlights = {
        -- Floats with cyan borders and no background
        FloatBorder = { fg = '$cyan', bg = '$none' },
        NormalFloat = { bg = '$none' },
    },
}
onedark.load()

return require('onedark.colors')
