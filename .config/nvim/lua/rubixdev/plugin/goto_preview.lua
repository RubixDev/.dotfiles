local goto_preview = require('goto-preview')

goto_preview.setup {
    default_mappings = true,
    post_open_hook = function() vim.opt_local.signcolumn = 'no' end,
    border = 'rounded',
}
