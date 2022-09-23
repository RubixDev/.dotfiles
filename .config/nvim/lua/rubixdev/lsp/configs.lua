---------------
-- Utilities --
---------------
local handlers = require('rubixdev.lsp.handlers')
local utils = require('rubixdev.utils')

local default_opts = {
    on_attach = handlers.on_attach,
    capabilities = handlers.capabilities,
}

local function with_settings(settings)
    return vim.tbl_deep_extend('force', { settings = settings }, default_opts)
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

lspconfig.rust_analyzer.setup(with_settings {
    ['rust-analyzer'] = {
        checkOnSave = { command = 'clippy' },
    },
})
lspconfig.vimls.setup(default_opts)
lspconfig.bashls.setup(default_opts)
lspconfig.sumneko_lua.setup(with_settings {
    Lua = {
        runtime = {
            version = 'LuaJIT',
        },
        diagnostics = {
            globals = { 'vim' },
        },
        telemetry = {
            enable = false,
        },
    },
})
lspconfig.pylsp.setup(default_opts)
if vim.g.is_android == 0 then
    lspconfig.dockerls.setup(default_opts)
    lspconfig.golangci_lint_ls.setup(default_opts)
    lspconfig.gopls.setup(default_opts)
    lspconfig.jdtls.setup(default_opts)
    lspconfig.kotlin_language_server.setup(default_opts)
    lspconfig.gdscript.setup(default_opts)
    lspconfig.clangd.setup(default_opts)
    lspconfig.taplo.setup(default_opts)
    lspconfig.ltex.setup(with_settings {
        ltex = {
            additionalRules = {
                enablePickyRules = true,
                motherTongue = 'de-De',
            },
        },
    })
    lspconfig.texlab.setup(with_settings {
        texlab = {
            build = {
                args = {
                    '-xelatex', -- Build with xelatex
                    '-pdfxe', -- Build with xelatex
                    '-interaction=nonstopmode', -- Ignore errors
                    '-synctex=1', -- Enable SyncTeX
                    '-pv', -- Open preview
                    '%f',
                },
                onSave = true, -- Build on save
            },
            forwardSearch = {
                -- Use zathura for preview
                executable = 'zathura',
                args = { '--synctex-forward', '%l:1:%f', '%p' },
            },

            -- Set latexindent as formatter
            bibtexFormatter = 'latexindent',
            latexFormatter = 'latexindent',

            -- Enable chktex lints
            chktex = {
                onOpenAndSave = true,
                onEdit = true,
            },
        },
    })
    lspconfig.svelte.setup(default_opts)
    lspconfig.tsserver.setup(default_opts)
    lspconfig.cssls.setup(default_opts)
    lspconfig.html.setup(default_opts)
    lspconfig.emmet_ls.setup(default_opts)
    lspconfig.jsonls.setup(default_opts)
end
