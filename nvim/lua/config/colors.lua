-- enable termguicolors
vim.opt.termguicolors = true

-- vim.cmd('colorscheme onehalflight')

-- vim.o.background = 'light'
-- vim.g.gruvbox_material_foreground = 'material'
-- vim.g.gruvbox_material_background = 'medium'
vim.g.everforest_background = 'medium'
vim.cmd.colorscheme('everforest')

-- vim.g.everforest_background = 'hard'
-- vim.cmd('colorscheme everforest')

-- highlight spell check
vim.cmd([[
  function! MyHighlights() abort
    highlight SpellBad cterm=underline ctermfg=167 gui=undercurl guifg=#e45649
    highlight SpellCap cterm=underline ctermfg=136 gui=undercurl guifg=#c18401
    highlight SpellRare cterm=underline ctermfg=136 gui=undercurl guifg=#c18401
    highlight SpellLocal cterm=underline ctermfg=136 gui=undercurl guifg=#c18401
  endfunction

  augroup MyColors
    autocmd!
    autocmd ColorScheme * call MyHighlights()
  augroup END
]])
