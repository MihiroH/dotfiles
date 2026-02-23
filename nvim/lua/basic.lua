-- Encoding
vim.cmd('lang en_US.UTF-8')

-- Set Leader to Space
vim.g.mapleader = ' '

vim.keymap.set('n', '<Leader>w', ':w<CR>')
vim.keymap.set('n', '<Leader>q', ':q<CR>')
vim.keymap.set('n', '<Leader>wq', ':wq<CR>')

vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('n', '<C-l>', 'zz')
vim.keymap.set('n', '<S-*>', 'g*')

-- Center search results after jumping
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('n', '*', '*zz')
vim.keymap.set('n', '#', '#zz')
vim.keymap.set('n', 'g*', 'g*zz')
vim.keymap.set('n', 'g#', 'g#zz')

-- Quickfix
vim.keymap.set('n', 'cl', ':ccl<CR>')
vim.keymap.set('n', 'cn', ':cnext<CR>')
vim.keymap.set('n', 'cp', ':cprev<CR>')

vim.cmd('filetype on')
vim.cmd('filetype plugin indent on')

vim.cmd('syntax on')

vim.opt.guicursor = 'a:blinkon0'
vim.opt.iskeyword:remove('.')

-- Enable mouse
-- vim.opt.mouse = 'a'
-- Show text normally (prevent hiding double quotes in JSON, etc.)
vim.opt.conceallevel = 0
-- Set encoding to UTF-8
vim.opt.fileencoding = 'utf-8'
-- Disable backup files
vim.opt.backup = false
-- Disable swap files
vim.opt.swapfile = false
-- Auto-reload files when changed externally
vim.opt.autoread = true
-- Allow opening other files while buffer is unsaved
vim.opt.hidden = true
-- Show command being typed in status bar
vim.opt.showcmd = true
-- Show line numbers
vim.opt.number = true
-- Visual bell instead of beep
vim.opt.visualbell = true
-- Disable auto-commenting on newline
vim.opt.formatoptions:remove({ 'r', 'o' })
-- Always show status line
vim.opt.laststatus = 2
-- Command-line completion
vim.opt.wildmode = 'longest:full,full'
-- Show column guide at 120 characters
vim.opt.colorcolumn = '120'
-- Exclude patterns with vimgrep
vim.opt.wildignore:append('*/node_modules/**,*/dist/**,.**,*/tmp/*,*.so,*.swp,*.zip')
-- Spell check
-- vim.opt.spell = true
vim.opt.spelllang = 'en,cjk'
vim.opt.spellsuggest = 'best,9'

-- Search
-- Case-insensitive search when query is lowercase
vim.opt.ignorecase = true
-- Case-sensitive search when query contains uppercase
vim.opt.smartcase = true
-- Incremental search
vim.opt.incsearch = true
-- Wrap search around end of file
vim.opt.wrapscan = true
-- Highlight search results
vim.opt.hlsearch = true
-- Clear highlight with double Escape
vim.keymap.set('n', '<Esc><Esc>', ':nohlsearch<CR><Esc>')
-- Completion options
-- vim.opt.completeopt = 'menuone'
vim.opt.completeopt = 'menuone,noinsert,popup'

-- Yank to system clipboard
vim.opt.clipboard = 'unnamed'

vim.opt.splitright = true
vim.opt.splitbelow = true

-- Auto-open quickfix window after grep
vim.opt.modifiable = true
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  pattern = '*grep*',
  command = 'cwindow',
})

-- Tab display
vim.opt.list = true
vim.opt.listchars = 'tab:▸-'
-- vim.opt.listchars = 'tab:▸-,space:.'
vim.cmd('hi SpecialKey ctermbg=NONE ctermfg=100')
-- Always hide tabline
vim.opt.showtabline = 0
-- Use spaces instead of tabs
vim.opt.expandtab = true
-- Tab width (non-leading)
vim.opt.tabstop = 2
-- Tab width (leading)
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
-- Continue indent from previous line
vim.opt.autoindent = true
-- Smart indent based on syntax
vim.opt.smartindent = true
-- Go to previous tab
vim.keymap.set('n', 'gb', 'gT')

-- Open buffer in new tab
vim.api.nvim_create_user_command('B', function(opts)
  vim.cmd('tab sb' .. opts.args)
end, { nargs = 1 })

-- cd to current buffer's directory
vim.keymap.set('n', '<leader>cd', ':cd %:p:h<CR>:pwd<CR>')
-- Auto cd on BufEnter
-- vim.api.nvim_create_autocmd('BufEnter', { pattern = '*', command = 'silent! lcd %:p:h' })

-- Navigate in insert mode
vim.keymap.set('i', '<C-k>', '<Up>')
vim.keymap.set('i', '<C-j>', '<Down>')
vim.keymap.set('i', '<C-b>', '<Left>')
vim.keymap.set('i', '<C-f>', '<Right>')

-- Search selected text with * and # in visual mode
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

-- Store undo files in a single location
if vim.fn.has('persistent_undo') == 1 then
  vim.opt.undodir = vim.fn.expand('~/.vim/undo')
  vim.opt.undofile = true
end

-- Strip trailing whitespace on save (except markdown)
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

-- Highlight full-width spaces
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
