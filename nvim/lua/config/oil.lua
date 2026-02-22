local oil = require('oil')
local map = require('config.utils').map

oil.setup({
  default_file_explorer = true,
  view_options = {
    show_hidden = true,
  },
})

map('n', '<C-n>', function() oil.toggle_float() end)
