-- 文字コード
vim.cmd('lang en_US.UTF-8')

-- LeaderをSpaceキーにする
vim.g.mapleader = ' '

vim.keymap.set('n', '<Leader>w', ':w<CR>')
vim.keymap.set('n', '<Leader>q', ':q<CR>')
vim.keymap.set('n', '<Leader>wq', ':wq<CR>')

vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('n', '<C-l>', 'zz')
vim.keymap.set('n', '<S-*>', 'g*')

-- 検索後にジャンプした際に検索単語を画面中央に持ってくる
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('n', '*', '*zz')
vim.keymap.set('n', '#', '#zz')
vim.keymap.set('n', 'g*', 'g*zz')
vim.keymap.set('n', 'g#', 'g#zz')

-- quickfix
vim.keymap.set('n', 'cl', ':ccl<CR>')
vim.keymap.set('n', 'cn', ':cnext<CR>')
vim.keymap.set('n', 'cp', ':cprev<CR>')

vim.cmd('filetype on')
vim.cmd('filetype plugin indent on')

vim.cmd('syntax on')

vim.opt.guicursor = 'a:blinkon0'
vim.opt.iskeyword:remove('.')

-- マウスを有効
-- vim.opt.mouse = 'a'
-- テキストを通常どおり表示(JSONなどでダブルクオーテーションなどが非表示になるのを防ぐ)
vim.opt.conceallevel = 0
-- 文字コードをUFT-8に設定
vim.opt.fileencoding = 'utf-8'
-- バックアップファイルを作らない
vim.opt.backup = false
-- スワップファイルを作らない
vim.opt.swapfile = false
-- 編集中のファイルが変更されたら自動で読み直す
vim.opt.autoread = true
-- バッファが編集中でもその他のファイルを開けるように
vim.opt.hidden = true
-- 入力中のコマンドをステータスに表示する
vim.opt.showcmd = true
-- 行番号を表示
vim.opt.number = true
-- ビープ音を可視化
vim.opt.visualbell = true
-- vim で改行での自動コメントアウトを無効にする
vim.opt.formatoptions:remove({ 'r', 'o' })
-- ステータスラインを常に表示
vim.opt.laststatus = 2
-- コマンドラインの補完
vim.opt.wildmode = 'longest:full,full'
-- 120文字目にラインを入れる
vim.opt.colorcolumn = '120'
-- exclude patterns with vimgrep.
vim.opt.wildignore:append('*/node_modules/**,*/dist/**,.**,*/tmp/*,*.so,*.swp,*.zip')
-- spell check
-- vim.opt.spell = true
vim.opt.spelllang = 'en,cjk'
vim.opt.spellsuggest = 'best,9'

-- 検索系
-- 検索文字列が小文字の場合は大文字小文字を区別なく検索する
vim.opt.ignorecase = true
-- 検索文字列に大文字が含まれている場合は区別して検索する
vim.opt.smartcase = true
-- 検索文字列入力時に順次対象文字列にヒットさせる
vim.opt.incsearch = true
-- 検索時に最後まで行ったら最初に戻る
vim.opt.wrapscan = true
-- 検索語をハイライト表示
vim.opt.hlsearch = true
-- ESC連打でハイライト解除
vim.keymap.set('n', '<Esc><Esc>', ':nohlsearch<CR><Esc>')
-- 補完時のpreviewウィンドウを表示しない
-- vim.opt.completeopt = 'menuone'
vim.opt.completeopt = 'menuone,noinsert,popup'

-- yank
vim.opt.clipboard = 'unnamed'

vim.opt.splitright = true
vim.opt.splitbelow = true

-- 自動的にquickfix-windowを開く
vim.opt.modifiable = true
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  pattern = '*grep*',
  command = 'cwindow',
})

-- Tab
vim.opt.list = true
vim.opt.listchars = 'tab:▸-'
-- vim.opt.listchars = 'tab:▸-,space:.'
vim.cmd('hi SpecialKey ctermbg=NONE ctermfg=100')
-- 常にタブラインを非表示
vim.opt.showtabline = 0
-- Tab文字を半角スペースにする
vim.opt.expandtab = true
-- 行頭以外のTab文字の表示幅（スペースいくつ分）
vim.opt.tabstop = 2
-- 行頭でのTab文字の表示幅
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
-- 改行時に前の行のインデントを継続する
vim.opt.autoindent = true
-- 改行時に前の行の構文をチェックし次の行のインデントを増減する
vim.opt.smartindent = true
-- 左のタブに移動
vim.keymap.set('n', 'gb', 'gT')

-- バッファを新規タブで開く
vim.api.nvim_create_user_command('B', function(opts)
  vim.cmd('tab sb' .. opts.args)
end, { nargs = 1 })

-- 現在のバッファのディレクトリに移動
vim.keymap.set('n', '<leader>cd', ':cd %:p:h<CR>:pwd<CR>')
-- バッファを開いたときにpwdをcurrent directoryにする
-- vim.api.nvim_create_autocmd('BufEnter', { pattern = '*', command = 'silent! lcd %:p:h' })

-- insertmodeで移動
vim.keymap.set('i', '<C-k>', '<Up>')
vim.keymap.set('i', '<C-j>', '<Down>')
vim.keymap.set('i', '<C-b>', '<Left>')
vim.keymap.set('i', '<C-f>', '<Right>')

-- virtualモードの時にスターで選択位置のコードを検索するようにする
vim.keymap.set('x', '*', function()
  local save = vim.fn.getreg('s')
  vim.cmd('normal! gv"sy')
  local pattern = '\\V' .. vim.fn.escape(vim.fn.getreg('s'), '/\\'):gsub('\n', '\\n')
  vim.fn.setreg('/', pattern)
  vim.fn.setreg('s', save)
  vim.cmd('/' .. vim.fn.getreg('/'))
end)
vim.keymap.set('x', '#', function()
  local save = vim.fn.getreg('s')
  vim.cmd('normal! gv"sy')
  local pattern = '\\V' .. vim.fn.escape(vim.fn.getreg('s'), '/\\'):gsub('\n', '\\n')
  vim.fn.setreg('/', pattern)
  vim.fn.setreg('s', save)
  vim.cmd('?' .. vim.fn.getreg('/'))
end)

-- undoファイルを1箇所に保存
if vim.fn.has('persistent_undo') == 1 then
  vim.opt.undodir = vim.fn.expand('~/.vim/undo')
  vim.opt.undofile = true
end

-- 行末のスペースを削除(markdownファイル以外)
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function()
    if vim.bo.filetype == 'markdown' then
      return
    end
    local save_cursor = vim.fn.getpos('.')
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos('.', save_cursor)
  end,
})

-- 全角スペースをハイライト表示
local function zenkaku_space()
  vim.cmd('highlight ZenkakuSpace cterm=reverse ctermfg=DarkMagenta gui=reverse guifg=DarkMagenta')
end

if vim.fn.has('syntax') == 1 then
  local zenkaku_group = vim.api.nvim_create_augroup('ZenkakuSpace', { clear = true })
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = zenkaku_group,
    pattern = '*',
    callback = zenkaku_space,
  })
  vim.api.nvim_create_autocmd({ 'VimEnter', 'WinEnter' }, {
    group = zenkaku_group,
    pattern = '*',
    command = 'match ZenkakuSpace /　/',
  })
  zenkaku_space()
end

-- Pythonを有効化
vim.g.python3_host_prog = '/Users/mihiro/.anyenv/envs/pyenv/shims/python'

-- Copy the latest message to clipboard
vim.api.nvim_create_user_command('MesToClipboard', function()
  local content = vim.fn.execute('1messages'):gsub('[\r\n]', '')
  vim.fn.setreg('+', content)
  vim.notify('Copied: "' .. content .. '"')
end, {})
vim.keymap.set('n', '<Leader>cm', '<cmd>MesToClipboard<CR>')

-- Copy file path of current buffer to clipboard
vim.api.nvim_create_user_command('CopyFilePath', function()
  local path = vim.fn.expand('%')
  vim.fn.setreg('+', path)
  vim.notify('Copied: "' .. path .. '"')
end, {})
vim.keymap.set('n', '<Leader>cp', ':CopyFilePath<CR>')
