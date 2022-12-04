_G.is_android = vim.fn.executable('uname') == 1 and vim.fn.system('uname -o') == 'Android\n'

require('rubixdev.packer')
require('rubixdev.mappings')

vim.api.nvim_create_user_command('Shareclip', function() io.popen('zsh -i -c "shareclip"') end, {})
vim.api.nvim_create_user_command('Loadclip', function() io.popen('zsh -i -c "loadclip"') end, {})
