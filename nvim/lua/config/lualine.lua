require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = 'everforest',
  },

  sections = {
    lualine_x = { 'aerial' },
  },

  extensions = { 'fern', 'quickfix', }
})
