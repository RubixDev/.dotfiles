-- set shorter name for keymap function
local map = vim.keymap.set

-- Replace all with Shift+S
map('n', 'S', ':%s//g<left><left>')

-- Search results centered please
map('n', 'n', 'nzz', { silent = true })
map('n', 'N', 'Nzz', { silent = true })
map('n', '*', '*zz', { silent = true })
map('n', '#', '#zz', { silent = true })
map('n', 'g*', 'g*zz', { silent = true })

-- Ctrl+h to stop searching
map({ 'n', 'v' }, '<C-h>', ':nohlsearch<cr>')

-- Ctrl+k as Esc
map({ 'n', 'i', 'v', 's', 'x', 'o', 'l', 't' }, '<C-k>', '<Esc>')
map('c', '<C-k>', '<C-c>')

-- Move into wrapped lines
map('n', 'j', 'gj')
map('n', 'k', 'gk')

-- Jump to start and end of line using the home row keys
map('', 'H', '^')
map('', 'L', '$')

-- No arrow keys --- force yourself to use the home row (but not on android)
if vim.g.is_android == 0 then
    map('n', '<up>', '<nop>')
    map('n', '<down>', '<nop>')
    map('i', '<up>', '<nop>')
    map('i', '<down>', '<nop>')
    map('i', '<left>', '<nop>')
    map('i', '<right>', '<nop>')

    -- Left and right can switch buffers
    map('n', '<left>', ':bp<CR>')
    map('n', '<right>', ':bn<CR>')
end

-- <leader><leader> toggles between buffers
map('n', '<leader><leader>', '<C-^>')

-- Quick save and quit
map('n', '<leader>w', ':w<CR>')
map('n', '<leader>q', ':q<CR>')
map('n', '<leader>bd', ':bd<CR>')

-- Run Makefile
map('n', '<leader>m', ':!make<space>')
map('n', '<leader>M', ':!make<CR>')

-- Delete, not cut
map('n', '<leader>d', '"_d')
map('n', '<leader>c', '"_c')
map('n', '<leader>x', '"_x')
map('n', '<leader>D', '"_D')
map('n', '<leader>C', '"_C')

-- Git
map('n', '<leader>ga', ':Git add -p<CR>')
map('n', '<leader>gc', ':Git commit -v<CR>')
map('n', '<leader>gp', ':Git push<CR>')
map('n', '<leader>gl', ':Git pull<CR>')

-- Markdown
map('n', '<Leader>mp', ':MarkdownPreview<CR>')
map('n', '<Leader>mP', ':MarkdownPreviewStop<CR>')
map('n', '<Leader>mf', ':TableFormat<CR>')
map('n', '<Leader>mw', ':setlocal invwrap<CR>')
-- Set LTeX language to German in markdown files
map('n', '<Leader>ml', ':call append(line("0"), ["---", "lang: de-DE", "---", ""])<CR>')

-- Insert line above/below cursor without insert mode
map('', '<Leader>N', ':<C-U>call append(line(".")-1, repeat([""], v:count1))<CR>')
map('', '<Leader>n', ':<C-U>call append(line("."), repeat([""], v:count1))<CR>')

-- Set LTeX language to German in LaTeX files
map('n', '<leader>ll', ':call append(line("0"), ["% LTeX: language=de-DE"])<CR>')
-- Disable ChkTeX tabular warnings
map('n', '<leader>lt', ':call append(line("0"), ["% chktex-file -2"])<CR>')
-- Open/scroll LaTeX preview
map('n', '<leader>lp', ':TexlabForward<CR>')
-- Build LaTeX project
map('n', '<leader>lb', ':TexlabBuild<CR>')
