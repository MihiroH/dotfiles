" ↓update dein↓
" call dein#update()
" call dein#check_clean()
"
" How to cache clear.
" call map(dein#check_clean(), "delete(v:val, 'rf')")
" call dein#recache_runtimepath()

if !&compatible
  set nocompatible
endif

" reset augroup
augroup MyAutoCmd
  autocmd!
augroup END

" dein settings {{{
" dein自体の自動インストール
let s:cache_home = empty($XDG_CACHE_HOME) ? expand('~/.cache') : $XDG_CACHE_HOME
let s:dein_dir = s:cache_home . '/dein'
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if !isdirectory(s:dein_repo_dir)
  call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
endif
let &runtimepath = s:dein_repo_dir .",". &runtimepath
" プラグイン読み込み＆キャッシュ作成
let s:toml = fnamemodify(expand('<sfile>'), ':h').'/.vim/dein.toml'
let s:lazy_toml = fnamemodify(expand('<sfile>'), ':h').'/.vim/dein_lazy.toml'
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
  call dein#load_toml(s:toml, {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})
  call dein#end()
  call dein#save_state()
endif

let g:make = 'gmake'
if exists('make')
    let g:make = 'make'
endif

" use only python3
if has('python3')
  silent! python3 1
endif
" set pythonthreedll='/Users/mihiro/opt/anaconda3/bin/python'

" 不足プラグインの自動インストール
if has('vim_starting') && dein#check_install()
  call dein#install()
endif
" }}}

" syntax
syntax on

if has('autocmd') " ignore this section if your vim does not support autocommands
    " auto reload .vimrc
    augroup reload_vimrc
        autocmd!
        autocmd! BufWritePost $MYVIMRC,$MYGVIMRC nested source %
    augroup END
    " highlight
    " autocmd ColorScheme * highlight Search ctermfg=109
    " autocmd VimEnter,WinEnter,BufNewFile,BufRead,BufEnter,TabEnter * IndentLinesReset
endif

" config
" LeaderをSpaceキーにする
map <Space> <Leader>
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

" All the languages Kite supports
" let g:kite_supported_languages = ['*']
" set completeopt=menuone,noselect
" set belloff+=ctrlg  " if vim beeps during completion
" set statusline=%<%f\ %h%m%r%{kite#statusline()}%=%-14.(%l,%c%V%)\ %P
" set laststatus=2
" set completeopt+=menuone
" set completeopt-=noselect

lang en_US.UTF-8

" quickfix
nnoremap cl :ccl<CR>
nnoremap cn :cnext<CR>
nnoremap cp :cprev<CR>
filetype on
filetype plugin indent on
set guicursor=a:blinkon0
set iskeyword-=.
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
command! -nargs=1 B call TabSb(<f-args>)
function! TabSb(number)
  exe ":tab sb" . a:number
endfunction

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

" === markdown ===
command! Shiba :silent call system('shiba ' . expand('%') . ' &>/dev/null 2>&1 &') | redraw!
autocmd BufRead,BufNewFile *.md  set filetype=markdown
" nnoremap <silent> <C-m> :PrevimOpen<CR>
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0
