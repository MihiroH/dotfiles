local map = require('config.utils').map

-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = true,
  float = {
    border = 'rounded',
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '🥵',
      [vim.diagnostic.severity.WARN]  = '💩',
      [vim.diagnostic.severity.HINT]  = '💡',
      [vim.diagnostic.severity.INFO]  = '👀',
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Show diagnostics in a floating window when holding cursor
vim.api.nvim_create_autocmd('CursorHold', {
  callback = function()
    -- Skip if a floating window is already visible (e.g., hover documentation)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win).relative ~= '' then
        return
      end
    end
    vim.diagnostic.open_float(nil)
  end,
})

-- Shared capabilities (blink.cmp integration) for all servers
vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

-- Custom server configs

-- Vue / TypeScript hybrid mode
-- https://github.com/vuejs/language-tools/wiki/Neovim#configuration
local vue_language_server_path = vim.fn.stdpath('data') .. '/mason/packages/vue-language-server/node_modules/@vue/language-server'

vim.lsp.config('ts_ls', {
  init_options = {
    plugins = {
      {
        name = '@vue/typescript-plugin',
        location = vue_language_server_path,
        languages = { 'vue' },
      },
    },
  },
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
})

vim.lsp.config('vue_ls', {})

-- Suppress noisy ESLint config resolution errors (e.g. missing eslint-config-prettier)
do
  local original_notify = vim.notify
  vim.notify = function(msg, ...)
    if type(msg) == 'string' and msg:match('eslint') and (msg:match('Failed to load config') or msg:match('Failed to load plugin') or msg:match('Cannot read config file')) then
      return
    end
    return original_notify(msg, ...)
  end
end

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
        checkThirdParty = false,
      },
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
})

vim.lsp.config('sourcekit', {})
vim.lsp.enable('sourcekit')

-- Mason:
require('mason').setup({
  ui = {
    icons = {
      package_installed = '✓',
      package_pending = '➜',
      package_uninstalled = '✗'
    }
  }
})

-- Mason: auto-install and auto-enable LSP servers
require('mason-lspconfig').setup({
  ensure_installed = {
    'ts_ls',
    'vue_ls',
    'tailwindcss',
    'cssls',
    'html',
    'jsonls',
    -- 'gopls',
    'pyright',
    'svelte',
    'prismals',
    'dockerls',
    'yamlls',
    'sqlls',
    'graphql',
    'biome',
    'lua_ls',
    'eslint',
  },
})


-- Keybindings
local opts = { noremap = true, silent = true }

-- GoTo code navigation
map('n', 'gd', vim.lsp.buf.definition, opts)
map('n', 'gy', vim.lsp.buf.type_definition, opts)
map('n', 'gi', vim.lsp.buf.implementation, opts)
map('n', 'gr', vim.lsp.buf.references, opts)

-- Open definition in split/vsplit/tab
map('n', '<C-t>', function()
  print('Open definition in (s)plit / (v)split / (t)ab: ')
  local char = vim.fn.getcharstr()
  local cmd_map = { s = 'split', v = 'vsplit', t = 'tab split' }
  local cmd = cmd_map[char]
  if cmd then
    vim.cmd(cmd)
    vim.lsp.buf.definition()
  end
end, opts)

-- Show documentation
map('n', 'K', function()
  -- Close existing floating windows (e.g., diagnostic popups) so hover takes priority
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= '' then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
  vim.lsp.buf.hover({ border = 'rounded' })
end, opts)

-- Symbol renaming
map('n', '<Leader>rn', vim.lsp.buf.rename, opts)

-- Formatting
map('n', '<Leader>f', vim.lsp.buf.format, opts)
