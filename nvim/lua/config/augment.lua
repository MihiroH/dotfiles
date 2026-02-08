vim.g.augment_workspace_folders = {
  '~/Documents/personal/punk-ideas',
  '~/Documents/personal/settings-files',
  '~/Documents/personal/threey-smile',
  '~/Documents/personal/donrichy',
  '~/Documents/personal/meetogether',
  '~/Documents/personal/trace-suntory-site',
}

-- Key mappings
local map = require('config.utils').map
local opts = { noremap = true, silent = true }

map('i', '<C-E>', '<cmd>call augment#Accept()<CR>', opts)
map({ 'n', 'v' }, '<Leader>ac', '<cmd>Augment chat<CR>', opts)
map('n', '<Leader>an', '<cmd>Augment chat-new<CR>', opts)
map('n', '<Leader>at', '<cmd>Augment chat-toggle<CR>', opts)
