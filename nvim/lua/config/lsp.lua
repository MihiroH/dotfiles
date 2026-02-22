local map = require('config.utils').map

-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '🥵',
      [vim.diagnostic.severity.WARN]  = '💩',
      [vim.diagnostic.severity.HINT]  = '💡',
      [vim.diagnostic.severity.INFO]  = 'i',
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
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
  -- automatic_enable = true (default) calls vim.lsp.enable() for installed servers
})

-- LspAttach: buffer-local keybindings and per-client setup
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    -- Attach nvim-navic for barbecue breadcrumbs
    local has_navic, navic = pcall(require, 'nvim-navic')
    if has_navic and client.server_capabilities.documentSymbolProvider then
      navic.attach(client, bufnr)
    end

  end,
})

-- Keybindings
local opts = { noremap = true, silent = true }

-- GoTo code navigation
map('n', 'gd', vim.lsp.buf.definition, opts)
map('n', 'gy', vim.lsp.buf.type_definition, opts)
map('n', 'gi', vim.lsp.buf.implementation, opts)
map('n', 'gr', vim.lsp.buf.references, opts)

-- Show documentation
map('n', 'K', vim.lsp.buf.hover, opts)

-- CocJumpAction reimplementation
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

-- Symbol renaming
map('n', '<Leader>rn', vim.lsp.buf.rename, opts)

-- Code actions
map('n', '<Leader>cac', vim.lsp.buf.code_action, opts)

-- Apply quickfix to current line
map('n', '<Leader>qf', function()
  vim.lsp.buf.code_action({ context = { only = { 'quickfix' } } })
end, opts)

-- Code Lens
map('n', '<Leader>cl', vim.lsp.codelens.run, opts)

-- SCSS @ handling
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'scss',
  callback = function()
    vim.opt_local.iskeyword:append('@-@')
  end,
})

-- Commands
-- vim.api.nvim_create_user_command('ESLintFix', 'EslintFixAll', {})
-- vim.api.nvim_create_user_command('Prettier', function()
--   require('conform').format({ formatters = { 'prettier' }, async = true })
-- end, {})
-- vim.api.nvim_create_user_command('Format', '!npm run check', {})
-- vim.api.nvim_create_user_command('FormatPrisma', '!npm run format:prisma', {})
