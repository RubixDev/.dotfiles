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
    if client.resolved_capabilities.document_highlight then
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

local function lsp_keymaps(bufnr)
    local opts = { buffer = bufnr, silent = true }
    local map = vim.keymap.set
    local builtin = require('telescope.builtin')

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    map('n', 'gD', vim.lsp.buf.declaration, opts)
    map('n', 'gd', builtin.lsp_definitions, opts)
    map('n', 'K', show_documentation, opts)
    map('n', 'gi', builtin.lsp_implementations, opts)
    map('n', '<leader>D', builtin.lsp_type_definitions, opts)
    map('n', '<leader>r', vim.lsp.buf.rename, opts)
    map('n', '<leader>a', vim.lsp.buf.code_action, opts)
    map('n', 'gr', builtin.lsp_references, opts)
    map('n', '<leader>e', vim.diagnostic.open_float, opts)
    map('n', '[d', vim.diagnostic.goto_prev, opts)
    map('n', ']d', vim.diagnostic.goto_next, opts)
    map('n', ']D', builtin.diagnostics, opts)
    map('n', '<leader>f', vim.lsp.buf.formatting, opts)

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
    -- Disable formatting for some language servers
    local disabled_formatter = {
        svelte = true,
        tsserver = true,
        cssls = true,
        html = true,
        jsonls = true,
        sumneko_lua = true,
        pylsp = true,
    }
    if disabled_formatter[client.name] then client.resolved_capabilities.document_formatting = false end

    -- Disable formatter of null-ls if formatting is provided by other LSP
    local clients = vim.lsp.buf_get_clients()
    local null_ls_index = nil
    local has_other_formatter = false
    for i, lsp in ipairs(clients) do
        if lsp.name == 'null-ls' then
            null_ls_index = i
        elseif lsp.resolved_capabilities.document_formatting and not disabled_formatter[lsp.name] then
            has_other_formatter = true
        end
    end
    if null_ls_index ~= nil and has_other_formatter then
        clients[null_ls_index].resolved_capabilities.document_formatting = false
    end

    -- Add mappings
    lsp_keymaps(bufnr)
    -- LSP based highlighting
    lsp_highlight_document(client)
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
utils.try_setup(
    'cmp_nvim_lsp',
    function(cmp_nvim_lsp) M.capabilities = cmp_nvim_lsp.update_capabilities(M.capabilities) end
)

return M
