local lualine = require('lualine')

local onedark_ok, colors = pcall(require, 'rubixdev.onedark')
local onedark = require('lualine.utils.loader').load_theme('onedark')
if onedark_ok then
    -- Set middle section bg color to bg0 and fg color to match vi mode
    onedark = vim.tbl_deep_extend('force', onedark, {
        inactive = {
            c = { bg = vim.g.onedark_config.lualine.transparent and colors.none or colors.bg0 },
        },
        normal = {
            c = {
                fg = onedark.normal.a.bg,
                bg = vim.g.onedark_config.lualine.transparent and colors.none or colors.bg0,
            },
        },
        visual = { c = { fg = onedark.visual.a.bg } },
        replace = { c = { fg = onedark.replace.a.bg } },
        insert = { c = { fg = onedark.insert.a.bg } },
        command = { c = { fg = onedark.command.a.bg } },
        terminal = { c = { fg = onedark.terminal.a.bg } },
    })
end

local buffers_component = {
    'buffers',
    symbols = {
        alternate_file = '',
    },
}

local diagnostics_component = {
    'diagnostics',
    sources = { 'nvim_diagnostic' },
    symbols = {
        error = ' ',
        warn = ' ',
        info = ' ',
        hint = ' ',
    },
    -- TODO: show all diagnostics on click (requires nvim 0.8+)
    -- on_click = function()
    --     require('telescope.bultin').diagnostics()
    -- end,
}

local diff_component = {
    'diff',
    symbols = {
        added = ' ',
        modified = '柳',
        removed = ' ',
    },
}

local workspace_diagnostics_component = vim.tbl_deep_extend('force', diagnostics_component, {
    sources = { 'nvim_workspace_diagnostic' },
})

local filename_component = {
    'filename',
    newfile_status = true,
    path = 1,
    symbols = {
        modified = '●',
        readonly = '',
    },
}

local location_component = { '%l:%c' }
local progress_component = { '%p%%/%L' }

local lsp_progress_component = {
    function()
        return require('lsp-progress').progress()
    end,
}

lualine.setup {
    options = {
        icons_enabled = true,
        theme = onedark,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        ignore_focus = {},
        always_divide_middle = true,
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', diff_component, diagnostics_component },
        lualine_c = { filename_component },
        lualine_x = { lsp_progress_component, 'filetype' },
        lualine_y = { 'encoding', 'fileformat' },
        lualine_z = { location_component, progress_component },
    },
    inactive_sections = {
        lualine_c = { filename_component },
        lualine_x = { location_component, progress_component },
    },
    tabline = {
        lualine_a = { buffers_component },
        lualine_y = { workspace_diagnostics_component },
    },
}
