vim.cmd([[
  nnoremap <silent> <Leader>p :<C-u>FZFFileList<CR>
  nnoremap <silent> <Leader>. :GFiles<CR>
  nnoremap <silent> <Leader>, :<C-u>FZFMru<CR>
  nnoremap <silent> <Leader>l :<C-u>Lines<CR>
  nnoremap <silent> <Leader>b :<C-u>Buffers<CR>
  nnoremap <silent> <Leader>k :<C-u>Rg<CR>

  command! FZFFileList call fzf#run({
            \ 'source': 'rg --files --hidden',
            \ 'sink': 'e',
            \ 'options': '-m --border=none',
            \ 'down': '20%'})

  command! FZFMru call fzf#run({
             \ 'source': v:oldfiles,
             \ 'sink': 'e',
             \ 'options': '-m +s --border=none',
             \ 'down':  '20%'})

  let g:fzf_layout = {'up':'~90%', 'window': { 'width': 0.8, 'height': 0.8,'yoffset':0.5,'xoffset': 0.5, 'border': 'none' } }

  augroup vimrc_fzf
  autocmd!
  autocmd FileType fzf tnoremap <silent> <buffer> <Esc> <C-g>
  autocmd FileType fzf set laststatus=0 noshowmode noruler
       \| autocmd BufLeave <buffer> set laststatus=2 noshowmode ruler
  augroup END
]])
