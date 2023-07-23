vim.cmd([[
  let g:test#echo_command = 1
  let g:test#strategy = 'vimproc'
  let g:test#go#gotest#options = '-v -cover' " verbose output
  let test#go#runner = 'gotest'

  nmap <silent> <leader>t :TestNearest<CR>
  nmap <silent> <leader>T :TestFile<CR>
  nmap <silent> <leader>a :TestSuite<CR>
  nmap <silent> <leader>l :TestLast<CR>
  nmap <silent> <leader>g :TestVisit<CR>
]])
