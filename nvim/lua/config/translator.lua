vim.cmd([[
  let g:translator_target_lang = 'ja'

  " Echo translation in the cmdline
  nmap <silent> <Leader>T <Plug>Translate
  vmap <silent> <Leader>T <Plug>TranslateV
  " Display translation in a window
  nmap <silent> <Leader>W <Plug>TranslateW
  vmap <silent> <Leader>W <Plug>TranslateWV
  " Replace the text with translation
  nmap <silent> <Leader>R <Plug>TranslateR
  vmap <silent> <Leader>R <Plug>TranslateRV
  " Translate the text in clipboard
  nmap <silent> <Leader>X <Plug>TranslateX
]])
