vim.cmd([[
  let g:test#echo_command = 1
  let g:test#strategy = 'neovim'
  let g:test#go#gotest#options = '-v -cover' " verbose output
  let test#go#runner = 'gotest'

  nmap <silent> <leader>tn :TestNearest<CR>
  nmap <silent> <leader>tf :TestFile<CR>
  nmap <silent> <leader>ts :TestSuite<CR>
  nmap <silent> <leader>tL :TestLast<CR>
  nmap <silent> <leader>tv :TestVisit<CR>
]])
