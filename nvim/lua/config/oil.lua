local oil = require('oil')
local map = require('config.utils').map

oil.setup({
  default_file_explorer = true,
  view_options = {
    show_hidden = true,
  },
})

map('n', '<C-n>', function()
  oil.toggle_float()
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(0) and oil.get_cursor_entry() then
      oil.open_preview()
    end
  end)
end)
