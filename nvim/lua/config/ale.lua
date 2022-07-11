vim.cmd([[
  " 保存時のみ実行する
  let g:ale_lint_on_text_changed = 0

  " 表示に関する設定
  let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '⬥ ok']
  let g:ale_sign_error = '😡'
  let g:ale_sign_warning = '😩'
  let g:airline#extensions#ale#open_lnum_symbol = '('
  let g:airline#extensions#ale#close_lnum_symbol = ')'

  highlight link ALEErrorSign Tag
  highlight link ALEWarningSign StorageClass

  let g:ale_linters = {
  \   'javascript': ['eslint'],
  \   'python'    : ['flake8']
  \}
]])
