-- enable termguicolors
vim.opt.termguicolors = true

require('onedark').setup {
  style = 'cool'
}
require('onedark').load()

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

  " autocmd vimenter * ++nested colorscheme kanagawa
]])
