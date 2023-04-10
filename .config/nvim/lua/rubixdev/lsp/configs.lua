---------------
-- Utilities --
---------------
local handlers = require('rubixdev.lsp.handlers')
local utils = require('rubixdev.utils')

local default_opts = {
    on_attach = handlers.on_attach,
    capabilities = handlers.capabilities,
}

local function external(path)
    local config = require(path)

    local opts = {}
    opts.on_attach = handlers.on_attach
    opts.capabilities = handlers.capabilities
    opts.settings = config.settings

    if type(config.on_attach) == 'function' then
        opts.on_attach = function(client, bufnr)
            config.on_attach(client, bufnr)
            handlers.on_attach(client, bufnr)
        end
    end

    return opts
end

-----------
-- Mason --
-----------
utils.try_setup('mason', {
    ui = {
        border = 'rounded',
        icons = {
            package_installed = '✓',
            package_pending = '⟳',
            package_uninstalled = '✗',
        },
    },
})
utils.try_setup('mason-lspconfig', { automatic_installation = true })
require('rubixdev.lsp.null_ls')
require('rubixdev.lsp.crates_nvim')
utils.try_setup('mason-null-ls', { automatic_installation = true })
utils.try_setup('mason-update-all')

----------------------
-- Language Servers --
----------------------
local lspconfig = require('lspconfig')

lspconfig.bashls.setup(default_opts)
lspconfig.lua_ls.setup(external('rubixdev.lsp.configs.lua_ls'))
lspconfig.pylsp.setup(default_opts)
if not _G.is_android then
    lspconfig.rust_analyzer.setup(external('rubixdev.lsp.configs.rust_analyzer'))
    lspconfig.vimls.setup(default_opts)
    lspconfig.dockerls.setup(default_opts)
    lspconfig.golangci_lint_ls.setup(default_opts)
    lspconfig.gopls.setup(default_opts)
    lspconfig.jdtls.setup(default_opts)
    lspconfig.kotlin_language_server.setup(default_opts)
    lspconfig.gdscript.setup(default_opts)
    lspconfig.clangd.setup(default_opts)
    lspconfig.taplo.setup(default_opts)
    lspconfig.ltex.setup(external('rubixdev.lsp.configs.ltex'))
    lspconfig.texlab.setup(external('rubixdev.lsp.configs.texlab'))
    lspconfig.svelte.setup(default_opts)
    lspconfig.tsserver.setup(default_opts)
    lspconfig.cssls.setup(default_opts)
    lspconfig.html.setup(default_opts)
    lspconfig.emmet_ls.setup(default_opts)
    lspconfig.jsonls.setup(default_opts)

    -- rush language server
    local util = require('lspconfig/util')
    local configs = require('lspconfig/configs')
    configs.rush = {
        default_config = {
            cmd = { 'rush-ls' },
            filetypes = { 'rush' },
            root_dir = util.root_pattern('.git', '.rush'),
            single_file_support = true,
            settings = {},
            init_options = {},
        },
    }
    configs.rush.setup { default_opts }
end
