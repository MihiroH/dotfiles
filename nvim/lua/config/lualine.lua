require('lualine').setup {
  sections = {
    lualine_c = {
      {'filename',
        path = 1, -- 1: Relative path
      }
    }
  },
  extensions = { 'fern', 'quickfix', }
}
