local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
    return
end

require('rubixdev.lsp.configs')
require('rubixdev.lsp.handlers').setup()
