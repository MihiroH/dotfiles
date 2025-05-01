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
  -- Move if the Aerial window is opened
  vim.defer_fn(function()
    -- Search for the Aerial window and move
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == "aerial" then
        vim.api.nvim_set_current_win(win)
        break
      end
    end
  end, 100) -- Wait 100ms to ensure it is opened
end, opts)
