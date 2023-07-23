vim.cmd([[
  " 保存時のみ実行する
  let g:ale_lint_on_text_changed = 0

  " 保存時に自動フォーマットしない
  let g:ale_fix_on_save = 0

  " 表示に関する設定
  let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '⬥ ok']
  let g:ale_sign_error = '🥵'
  let g:ale_sign_warning = '💩'
  let g:airline#extensions#ale#open_lnum_symbol = '('
  let g:airline#extensions#ale#close_lnum_symbol = ')'

  highlight link ALEErrorSign Tag
  highlight link ALEWarningSign StorageClass

  let b:ale_linters = {
  \   'css': ['stylelint'],
  \   'scss': ['stylelint'],
  \   'javascript': ['eslint'],
  \   'typescript': ['eslint'],
  \   'typescriptreact': ['eslint'],
  \   'vue': ['eslint', 'volar'],
  \   'python' : ['flake8'],
  \   'go' : ['staticcheck'],
  \}

  let b:ale_fixers = {
  \   'css': ['prettier', 'stylelint'],
  \   'scss': ['prettier', 'stylelint'],
  \   'javascript': ['prettier', 'eslint'],
  \   'typescript': ['prettier', 'eslint'],
  \   'typescriptreact': ['prettier', 'eslint'],
  \   'vue': ['prettier', 'eslint'],
  \   'json': ['prettier'],
  \   'python': ['flake8'],
  \   'go': ['gofmt'],
  \}
]])
