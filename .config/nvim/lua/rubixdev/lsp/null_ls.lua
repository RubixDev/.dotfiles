local handlers = require('rubixdev.lsp.handlers')
local utils = require('rubixdev.utils')

local function not_android() return not _G.is_android end

utils.try_setup('null-ls', function(null_ls)
    null_ls.setup {
        on_attach = handlers.on_attach,
        sources = {
            -- null_ls.builtins.code_actions.shellcheck.with { filter = not_android }, -- Code actions to disable shellcheck warnings

            null_ls.builtins.diagnostics.actionlint.with { filter = not_android },  -- GitHub Actions workflow
            null_ls.builtins.diagnostics.gitlint.with {
                extra_args = { '--ignore', 'body-is-missing' },
            },                                                                       -- Commit messages
            null_ls.builtins.diagnostics.markdownlint.with { filter = not_android }, -- Markdown files
            null_ls.builtins.diagnostics.sqlfluff.with {
                extra_args = { '--dialect', 'postgres' },
                filter = not_android,
            },                                                              -- SQL
            null_ls.builtins.diagnostics.todo_comments,                     -- Warn at TODO commments
            null_ls.builtins.diagnostics.trail_space,                       -- Warn at trailing spaces
            null_ls.builtins.diagnostics.zsh,                               -- Very basic zsh linting

            -- null_ls.builtins.formatting.blue.with { filter = not_android }, -- Better python formatter
            -- null_ls.builtins.formatting.dprint.with(require('rubixdev.lsp.dprint')),
            null_ls.builtins.formatting.shfmt.with {
                -- Does not support zsh specific things, but enable it anyway
                extra_filetypes = { 'bash', 'zsh' },
                extra_args = { '--indent', '4', '--binary-next-line', '--case-indent', '--space-redirects' },
            },                                           -- Shell scripts
            null_ls.builtins.formatting.trim_newlines,   -- Trim trailing newlines
            null_ls.builtins.formatting.trim_whitespace, -- Trim trailing whitespace

            null_ls.builtins.hover.printenv,             -- Show value of env variable
        },
    }
end)
