" 文字コード
lang en_US.UTF-8

" LeaderをSpaceキーにする
let mapleader = "\<Space>"

nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>wq :wq<CR>

nnoremap j gj
nnoremap k gk
nnoremap <C-l> zz
nnoremap <S-*> g*

" 検索後にジャンプした際に検索単語を画面中央に持ってくる
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

" quickfix
nnoremap cl :ccl<CR>
nnoremap cn :cnext<CR>
nnoremap cp :cprev<CR>

filetype on
filetype plugin indent on

set guicursor=a:blinkon0
set iskeyword-=.

" マウスを有効
set mouse=a
" テキストを通常どおり表示(JSONなどでダブルクオーテーションなどが非表示になるのを防ぐ)
set conceallevel=0
" 文字コードをUFT-8に設定
set fenc=utf-8
" バックアップファイルを作らない
set nobackup
" スワップファイルを作らない
set noswapfile
" 編集中のファイルが変更されたら自動で読み直す
set autoread
" バッファが編集中でもその他のファイルを開けるように
set hidden
" 入力中のコマンドをステータスに表示する
set showcmd
" 行番号を表示
set number
" ビープ音を可視化
set visualbell
" vim で改行での自動コメントアウトを無効にする
set formatoptions-=ro
" ステータスラインを常に表示
set laststatus=2
" コマンドラインの補完
set wildmode=longest:full,full
" 80文字目にラインを入れる
set colorcolumn=80
" exclude patterns with vimgrep.
set wildignore+=*/node_modules/**,*/dist/**,.**,*/tmp/*,*.so,*.swp,*.zip

" 検索系
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch
" 検索時に最後まで行ったら最初に戻る
set wrapscan
" 検索語をハイライト表示
set hlsearch
" ESC連打でハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>
" 補完時のpreviewウィンドウを表示しない
" set completeopt=menuone

" yank
set clipboard=unnamed

set splitright
set splitbelow

" 自動的にquickfix-windowを開く
set modifiable
autocmd QuickFixCmdPost *grep* cwindow

" Tab
set list
set listchars=tab:\▸\-
" set listchars=tab:\▸\-,space:.
hi SpecialKey ctermbg=NONE ctermfg=100
" 常にタブラインを表示
set showtabline=2
" Tab文字を半角スペースにする
set expandtab
" 行頭以外のTab文字の表示幅（スペースいくつ分）
set tabstop=2
" 行頭でのTab文字の表示幅
set shiftwidth=2
set softtabstop=2
" 改行時に前の行のインデントを継続する
set autoindent
" 改行時に前の行の構文をチェックし次の行のインデントを増減する
set smartindent
" 左のタブに移動
nnoremap gb gT

" バッファを新規タブで開く
function! TabSb(number)
  exe ":tab sb" . a:number
endfunction

command! -nargs=1 B call TabSb(<f-args>)

" insertmodeで移動
imap <C-k> <Up>
imap <C-j> <Down>
imap <C-b> <Left>
imap <C-f> <Right>

" virtualモードの時にスターで選択位置のコードを検索するようにする"
xnoremap * :<C-u>call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch()<CR>?<C-R>=@/<CR><CR>
function! s:VSetSearch()
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

" undoファイルを1箇所に保存
if has('persistent_undo')
  set undodir=~/.vim/undo
  set undofile
endif

" 行末のスペースを削除(markdownファイル以外)
fun! StripTrailingWhitespace()
    " Don't strip on these filetypes
    if &ft =~ 'markdown'
        return
    endif
    %s/\s\+$//e
endfun

autocmd BufWritePre * call StripTrailingWhitespace()

"全角スペースをハイライト表示
function! ZenkakuSpace()
    highlight ZenkakuSpace cterm=reverse ctermfg=DarkMagenta gui=reverse guifg=DarkMagenta
endfunction

if has('syntax')
    augroup ZenkakuSpace
        autocmd!
        autocmd ColorScheme       * call ZenkakuSpace()
        autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
    augroup END
    call ZenkakuSpace()
endif

" coc.vim
" coc.nvim-specific settings
"
" Load coc manually
" Load coc configs when plugin is loaded
autocmd! User coc.nvim call LoadCocConfig()

function! LoadCocConfig() abort
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
    \ 'coc-css',
    \ 'coc-cssmodules',
    \ 'coc-docker',
    \ 'coc-emmet',
    \ 'coc-eslint',
    \ 'coc-flutter',
    \ 'coc-go',
    \ 'coc-html',
    \ 'coc-json',
    \ 'coc-lua',
    \ 'coc-pairs',
    \ 'coc-phpls',
    \ 'coc-snippets',
    \ 'coc-svelte',
    \ 'coc-tabnine',
    \ 'coc-tailwindcss',
    \ 'coc-tsserver',
    \ 'coc-vetur',
    \ 'coc-yaml',
  \]

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

  " Use K to show documentation in preview window.
  nmap <silent> gK :call <SID>show_documentation()<CR>

  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      call CocActionAsync('doHover')
    endif
  endfunction
endfunction
