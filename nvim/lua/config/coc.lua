vim.cmd([[
  " use <tab> for trigger completion and navigate to the next complete item
  function! CheckBackspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  inoremap <silent><expr> <Tab>
        \ coc#pum#visible() ? coc#pum#next(1) :
        \ CheckBackspace() ? "\<Tab>" :
        \ coc#refresh()

  inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
  inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"
  inoremap <silent><expr> <CR> coc#pum#visible() ? coc#_select_confirm() : "\<C-g>u\<CR>"

  let g:coc_status_error_sign = '😡'
  let g:coc_status_warning_sign = '😩'

  " default extensions
  let g:coc_global_extensions = [
    \ '@yaegassy/coc-volar',
    \ '@yaegassy/coc-volar-tools',
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
    \ 'coc-webview',
    \ 'coc-yaml',
    \ 'coc-prettier',
    \ 'coc-nav',
    \ 'coc-biome',
    \ 'coc-prisma',
    \ 'coc-sql',
    \ 'coc-pyright',
  \]

  " Markdown preview
  nnoremap <C-s> :CocCommand markdown-preview-enhanced.openPreview<CR>

  autocmd FileType scss setl iskeyword+=@-@

  " autofix linting for JS
  " autocmd FileType javascript,typescript,typescriptreact,vue,svelte nnoremap <silent><buffer><Leader>ce :CocCommand eslint.executeAutofix<CR>
  command! -nargs=0 ESLintFix :CocCommand eslint.executeAutofix
  " format buffer
  command! -nargs=0 Prettier :CocCommand prettier.forceFormatDocument
  " nnoremap <silent> <Leader>cf :call CocActionAsync('format')<CR>
  command! -nargs=0 Format :!npm run check
  command! -nargs=0 FormatPrisma :!npm run format:prisma

  " GoTo code navigation
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)

  " NOTE: text must contains '()' to detect input and its must be 1 character
  function! ChoseAction(actions) abort
    echo join(map(copy(a:actions), { _, v -> v.text }), ", ") .. ": "
    let result = getcharstr()
    let result = filter(a:actions, { _, v -> v.text =~# printf(".*\(%s\).*", result)})
    return len(result) ? result[0].value : ""
  endfunction

  function! CocJumpAction() abort
    let actions = [
      \ {"text": "(s)plit", "value": "split"},
      \ {"text": "(v)slit", "value": "vsplit"},
      \ {"text": "(t)ab", "value": "tabedit"},
      \ {"text": "(n)ew", "value": "tabnew"},
    \]
    return ChoseAction(actions)
  endfunction

  nnoremap <silent> <C-t> :<C-u>call CocActionAsync('jumpDefinition', CocJumpAction())<CR>

  " Symbol renaming.
  nmap <Leader>rn <Plug>(coc-rename)

  " Use K to show documentation in preview window.
  nnoremap <silent> K :call ShowDocumentation()<CR>

  function! ShowDocumentation()
    if CocAction('hasProvider', 'hover')
      call CocActionAsync('doHover')
    else
      call feedkeys('K', 'in')
    endif
  endfunction

  " Remap keys for applying codeAction to the current buffer.
  nmap <Leader>cac  <Plug>(coc-codeaction)
  " Apply AutoFix to problem on the current line.
  nmap <Leader>qf  <Plug>(coc-fix-current)

  " Run the Code Lens action on the current line.
  nmap <Leader>cl  <Plug>(coc-codelens-action)
]])
