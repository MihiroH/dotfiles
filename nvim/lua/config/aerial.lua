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
end, opts)
