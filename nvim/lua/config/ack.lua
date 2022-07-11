vim.cmd([[
  let g:ack_mappings = {
      \ "t": "",
      \ "T": "",
      \ "o": "",
      \ "O": "",
      \ "go": "",
      \ "h": "",
      \ "H": "",
      \ "v": "",
      \ "gv": "" }

  if executable('rg')
    let g:ackprg = 'rg --vimgrep -S'
  endif
]])
