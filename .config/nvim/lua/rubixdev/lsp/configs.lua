local handlers = require('rubixdev.lsp.handlers')
local default_opts = {
    on_attach = handlers.on_attach,
    capabilities = handlers.capabilities,
}

local function merge_opts(new_opts)
    return vim.tbl_deep_extend('force', new_opts, default_opts)
end

local function with_settings(settings)
    return merge_opts {
        settings = settings,
    }
end

local default_no_formatter = merge_opts {
    init_options = {
        provideFormatter = false,
    },
}

require('nvim-lsp-installer').setup(merge_opts { automatic_installation = true })
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
    require('lspconfig').svelte.setup(default_no_formatter)
    require('lspconfig').tsserver.setup(default_no_formatter)
    require('lspconfig').cssls.setup(default_no_formatter)
    require('lspconfig').html.setup(default_no_formatter)
    require('lspconfig').emmet_ls.setup(default_opts)
    require('lspconfig').jsonls.setup(default_no_formatter)
    require('prettier').setup {
        bin = 'prettier',
        filetypes = {
            'css',
            'scss',
            'html',
            'javascript',
            'typescript',
            'json',
            'json5',
            'svelte',
        },

        -- Do not restrict prettier to npm projects
        ['null-ls'] = {
            condition = function() return true end,
        },

        -- Default prettier settings
        arrow_parens = 'avoid',
        semi = false,
        single_quote = true,
        tab_width = 4,
        trailing_comma = 'all',
    }
    require('null-ls').setup(merge_opts {
        sources = {
            require('null-ls').builtins.code_actions.gitsigns
        }
    })
end
