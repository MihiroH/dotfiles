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
    vim.diagnostic.open_float(nil)
  end,
})

-- Shared capabilities (blink.cmp integration) for all servers
vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

-- Custom server configs

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

-- Mason: auto-install and auto-enable LSP servers
require('mason-lspconfig').setup({
  ensure_installed = {
    'ts_ls',
    'volar',
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
map('n', 'K', vim.lsp.buf.hover, opts)

-- Symbol renaming
map('n', '<Leader>rn', vim.lsp.buf.rename, opts)

-- Formatting
map('n', '<Leader>f', vim.lsp.buf.format, opts)
