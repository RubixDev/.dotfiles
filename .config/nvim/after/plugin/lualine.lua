local status_ok, lualine = pcall(require, 'lualine')
if not status_ok then
    return
end

local onedark_status_ok, colors = pcall(require, 'rubixdev.onedark')
local onedark = require('lualine.utils.loader').load_theme('onedark')
if onedark_status_ok then
    -- Set middle section bg color to bg, instead of bg1
    onedark.normal.c.bg = vim.g.onedark_config.lualine.transparent and colors.none or colors.bg0
    onedark.inactive.c.bg = vim.g.onedark_config.lualine.transparent and colors.none or colors.bg0

    -- Set middle section fg color to green
    onedark.normal.c.fg = colors.green
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

local progress_component = {
    function()
        local cur = vim.fn.line('.')
        local total = vim.fn.line('$')
        local col = vim.fn.virtcol('.')
        return math.floor(cur / total * 100) .. '%% ' .. cur .. '/' .. total .. string.format(' :%-2d', col)
    end,
}

-- Taken from AstroNvim: https://github.com/AstroNvim/AstroNvim/blob/90592994b1794f5b88268b21bb63f367096b57cb/lua/core/status.lua#L60-L73
local lsp_progress_component = {
    function()
       local lsp = vim.lsp.util.get_progress_messages()[1]
        return vim.lsp.util.get_progress_messages()[1]
            and string.format(
                " %%<%s %s %s (%s%%%%) ",
                ((lsp.percentage or 0) >= 99 and { "", "", "" } or { "", "", "" })[math.floor(
                    vim.loop.hrtime() / 12e7
                ) % 3 + 1],
                lsp.title or "",
                lsp.message or "",
                lsp.percentage or 0
            )
            or ""
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
        lualine_b = { 'branch', 'diff', diagnostics_component },
        lualine_c = { filename_component },
        lualine_x = { lsp_progress_component, 'filetype' },
        lualine_y = { 'encoding', 'fileformat' },
        lualine_z = { progress_component }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { progress_component },
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {
        lualine_a = { buffers_component },
        lualine_y = { workspace_diagnostics_component },
    },
}
