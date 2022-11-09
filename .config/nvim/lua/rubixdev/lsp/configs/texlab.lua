return {
    settings = {
        texlab = {
            build = {
                args = {
                    '-xelatex', -- Build with xelatex
                    '-shell-escape', -- Allow running shell commands from LaTeX
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
    },
    on_attach = function(_, bufnr)
        local map = vim.keymap.set
        local opts = { buffer = bufnr }

        -- Disable ChkTeX tabular warnings
        map('n', '<leader>lt', ':call append(line("0"), ["% chktex-file -2"])<CR>', opts)
        -- Open/scroll LaTeX preview
        map('n', '<leader>lp', ':TexlabForward<CR>', opts)
        -- Build LaTeX project
        map('n', '<leader>lb', ':TexlabBuild<CR>', opts)
    end,
}
