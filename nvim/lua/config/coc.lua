vim.cmd([[
  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  inoremap <silent><expr> <TAB>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ coc#refresh()

  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

  " default extensions
  let g:coc_global_extensions = [
    \ '@yaegassy/coc-volar',
    \ '@yaegassy/coc-tailwindcss3',
    \ 'coc-css',
    \ 'coc-cssmodules',
    \ 'coc-docker',
    \ 'coc-eslint',
    \ 'coc-flutter',
    \ 'coc-go',
    \ 'coc-html',
    \ 'coc-json',
    \ 'coc-lua',
    \ 'coc-markdown-preview-enhanced',
    \ 'coc-pairs',
    \ 'coc-phpls',
    \ 'coc-svelte',
    \ 'coc-tabnine',
    \ 'coc-tailwindcss',
    \ 'coc-tsserver',
    \ 'coc-vetur',
    \ 'coc-webview',
    \ 'coc-yaml',
  \]

  " Markdown preview
  nnoremap <C-s> :CocCommand markdown-preview-enhanced.openPreview<CR>

  autocmd FileType scss setl iskeyword+=@-@

  " autofix linting for JS
  autocmd FileType javascript,typescript,vue,svelte nnoremap <silent><buffer><Leader>ll :CocCommand eslint.executeAutofix<CR>
  " format buffer
  nnoremap <silent> <Leader>ll :call CocActionAsync('format')<CR>

  " GoTo code navigation
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)

  " Symbol renaming.
  nmap <Leader>rn <Plug>(coc-rename)

  " Use K to show documentation in preview window.
  nmap <silent> gK :call <SID>show_documentation()<CR>

  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      call CocActionAsync('doHover')
    endif
  endfunction
]])
