require('crates').setup {
    date_format = '%d.%m.%Y',
    notification_title = 'crates.nvim',
    popup = {
        border = 'rounded',
        keys = {
            hide = { 'q', '<esc>', '<C-k>' },
        },
    },
    null_ls = {
        enabled = true,
        name = 'crates.nvim',
    },
}
