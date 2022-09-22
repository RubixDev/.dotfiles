local handlers = require('rubixdev.lsp.handlers')

local null_ls_ok, null_ls = pcall(require, 'null-ls')
if not null_ls_ok then
    return
end

null_ls.setup({
    on_attach = handlers.on_attach,
    sources = {
        null_ls.builtins.code_actions.gitsigns,
        null_ls.builtins.formatting.stylua,
    },
})
