local utils = require('rubixdev.utils')

local M = {}

M.setup = function()
    local signs = {
        { name = 'DiagnosticSignError', text = '' },
        { name = 'DiagnosticSignWarn', text = '' },
        { name = 'DiagnosticSignInfo', text = '' },
        { name = 'DiagnosticSignHint', text = '' },
    }

    for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = '' })
    end

    vim.diagnostic.config {
        severity_sort = true,
        update_in_insert = true,
    }

    vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = true,
        signs = true,
        update_in_insert = true,
    })

    -- Set rounded float border for all handlers
    local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or 'rounded'
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
    end

    -- Set border of :LspInfo window
    require('lspconfig.ui.windows').default_options.border = 'rounded'
end

-- Enable dynamic highlighting from LSP
local function lsp_highlight_document(client)
    -- Set autocommands conditional on server_capabilities
    if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_exec(
            [[
                augroup lsp_document_highlight
                    autocmd! * <buffer>
                    autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                    autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
                augroup END
            ]],
            false
        )
    end
end

local function show_documentation()
    local filetype = vim.bo.filetype
    if vim.tbl_contains({ 'vim', 'help' }, filetype) then
        vim.cmd('help ' .. vim.fn.expand('<cword>'))
    elseif vim.tbl_contains({ 'man' }, filetype) then
        vim.cmd('Man ' .. vim.fn.expand('<cword>'))
    elseif vim.fn.expand('%:t') == 'Cargo.toml' and require('crates').popup_available() then
        require('crates').show_popup()
    else
        vim.lsp.buf.hover()
    end
end

local function code_actions()
    local ok, menu = pcall(require, 'code_action_menu')
    if ok then
        menu.open_code_action_menu()
    else
        vim.lsp.buf.code_action()
    end
end

local function format()
    local disabled_formatter = {
        svelte = true,
        ts_ls = true,
        cssls = true,
        html = true,
        jsonls = true,
        sumneko_lua = true,
        pylsp = true,
        taplo = true,
        dockerls = true,
    }

    vim.lsp.buf.format {
        filter = function(client)
            -- Disable formatting for some language servers
            if disabled_formatter[client.name] then return false end

            -- Disable formatter of null-ls if formatting is provided by another LSP
            if client.name ~= 'null-ls' then return true end
            local clients = vim.lsp.buf_get_clients()
            local has_other_formatter = false
            for _, lsp in ipairs(clients) do
                if
                    lsp.name ~= 'null-ls'
                    and lsp.server_capabilities.documentFormattingProvider
                    and not disabled_formatter[lsp.name]
                then
                    has_other_formatter = true
                end
            end
            if has_other_formatter then return false end
            return true
        end,
    }
end

local function lsp_keymaps(bufnr)
    local opts = { buffer = bufnr, silent = true }
    local map = vim.keymap.set
    local telescope = require('telescope.builtin')

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    map('n', 'gD', vim.lsp.buf.declaration, opts)
    map('n', 'gd', telescope.lsp_definitions, opts)
    map('n', 'K', show_documentation, opts)
    map('n', 'gi', telescope.lsp_implementations, opts)
    map('n', '<leader>D', telescope.lsp_type_definitions, opts)
    map('n', '<leader>r', vim.lsp.buf.rename, opts)
    map('n', '<leader>a', code_actions, opts)
    map('n', 'gr', telescope.lsp_references, opts)
    map('n', '<leader>e', vim.diagnostic.open_float, opts)
    map('n', '[d', vim.diagnostic.goto_prev, opts)
    map('n', ']d', vim.diagnostic.goto_next, opts)
    map('n', ']D', telescope.diagnostics, opts)
    map('n', '<leader>f', format, opts)

    -- Get signatures when in argument lists.
    utils.try_setup(
        'lsp_signature',
        function(lsp_signature)
            lsp_signature.on_attach({
                bind = true,
                handler_opts = {
                    border = 'rounded',
                },
            }, bufnr)
        end
    )
end

M.on_attach = function(client, bufnr)
    -- Add mappings
    lsp_keymaps(bufnr)
    -- LSP based highlighting
    lsp_highlight_document(client)
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
utils.try_setup('cmp_nvim_lsp', function(cmp_nvim_lsp) M.capabilities = cmp_nvim_lsp.default_capabilities() end)

return M
