vim.cmd([[
  imap <silent><script><expr> <C-E> copilot#Accept("\<CR>")
  let g:copilot_no_tab_map = v:true

  imap <C-=> <Plug>(copilot-dismiss)
  imap <C-]> <Plug>(copilot-next)
]])
