local handlers = require('rubixdev.lsp.handlers')
local default_opts = {
    on_attach = handlers.on_attach,
    capabilities = handlers.capabilities,
}

local function with_settings(settings)
    return vim.tbl_deep_extend('force', { settings = settings }, default_opts)
end

-- Mason: automatic installation of LSPs and null-ls sources
require('mason').setup {
    ui = {
        border = 'rounded',
        icons = {
            package_installed = '✓',
            package_pending = '⟳',
            package_uninstalled = '✗',
        },
    },
}
require('mason-lspconfig').setup { automatic_installation = true }
require('rubixdev.lsp.null_ls')
require('rubixdev.lsp.crates_nvim')
require('mason-null-ls').setup { automatic_installation = true }
require('mason-update-all').setup()

----------------------
-- Language Servers --
----------------------
require('lspconfig').rust_analyzer.setup(with_settings {
    ['rust-analyzer'] = {
        checkOnSave = { command = 'clippy' },
    },
})
require('lspconfig').vimls.setup(default_opts)
require('lspconfig').bashls.setup(default_opts)
require('lspconfig').sumneko_lua.setup(with_settings {
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
require('lspconfig').pylsp.setup(default_opts)
if vim.g.is_android == 0 then
    require('lspconfig').dockerls.setup(default_opts)
    require('lspconfig').golangci_lint_ls.setup(default_opts)
    require('lspconfig').gopls.setup(default_opts)
    require('lspconfig').jdtls.setup(default_opts)
    require('lspconfig').kotlin_language_server.setup(default_opts)
    require('lspconfig').gdscript.setup(default_opts)
    require('lspconfig').clangd.setup(default_opts)
    require('lspconfig').taplo.setup(default_opts)
    require('lspconfig').ltex.setup(with_settings {
        ltex = {
            additionalRules = {
                enablePickyRules = true,
                motherTongue = 'de-De',
            },
        },
    })
    require('lspconfig').texlab.setup(with_settings {
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
    require('lspconfig').svelte.setup(default_opts)
    require('lspconfig').tsserver.setup(default_opts)
    require('lspconfig').cssls.setup(default_opts)
    require('lspconfig').html.setup(default_opts)
    require('lspconfig').emmet_ls.setup(default_opts)
    require('lspconfig').jsonls.setup(default_opts)
end
