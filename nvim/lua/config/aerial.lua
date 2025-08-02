local present, aerial = pcall(require, 'aerial')

if not present then return end

local map = require('config.utils').map
local opts = { noremap = true, silent = true }

aerial.setup({
  autojump = true,

  layout = {
    default_direction = 'left',
  },

  keymaps = {
    ['l'] = 'actions.jump',
  },

  -- on_attach = function(bufnr)
  --   -- Jump forwards/backwards with '{' and '}'
  --   map('n', '{', '<cmd>AerialPrev<CR>', vim.tbl_extend('force', opts, { buffer = bufnr }))
  --   map('n', '}', '<cmd>AerialNext<CR>', vim.tbl_extend('force', opts, { buffer = bufnr }))
  -- end,
})

-- Key mappings
map('n', '<leader>a', function()
  vim.cmd('AerialToggle!')
  -- Move to Aerial window if it was opened
  vim.defer_fn(function()
    local aerial_win = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(win) then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "aerial" then
          aerial_win = win
          break
        end
      end
    end
    if aerial_win then
      vim.api.nvim_set_current_win(aerial_win)
    end
  end, 150)
end, opts)
