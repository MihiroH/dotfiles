local map = require('config.utils').map

vim.cmd([[
  function! s:init_fern() abort
    nmap <buffer> d <Plug>(fern-action-remove)
    nmap <buffer> cd <Plug>(fern-action-cd)
    nmap <buffer> r <Plug>(fern-action-reload:all)
  endfunction

  augroup my-fern
    autocmd! *
    autocmd FileType fern call s:init_fern()
  augroup END
]])

vim.g['fern#default_hidden'] = 1
vim.g['fern#renderer'] = 'nerdfont'

map('n', '<C-n>', ':Fern . -reveal=% -drawer -toggle<cr>')

-- アイコンに色をつける
vim.cmd([[
  augroup my-glyph-palette
    autocmd! *
    autocmd FileType fern call glyph_palette#apply()
  augroup END
]])
