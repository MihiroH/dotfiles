local lspconfig = require('lspconfig')
local map = require('config.utils').map

-- Diagnostic signs
local signs = {
  { name = 'DiagnosticSignError', text = '🥵' },
  { name = 'DiagnosticSignWarn', text = '💩' },
  { name = 'DiagnosticSignHint', text = '💡' },
  { name = 'DiagnosticSignInfo', text = 'i' },
}
for _, sign in ipairs(signs) do
  vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = '' })
end

-- Check if a binary exists before configuring a server
local function has_binary(name)
  return vim.fn.executable(name) == 1
end

-- Shared capabilities (nvim-cmp integration)
local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_cmp_lsp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
if has_cmp_lsp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- Shared on_attach
local on_attach = function(client, bufnr)
  -- Attach nvim-navic for barbecue breadcrumbs
  local has_navic, navic = pcall(require, 'nvim-navic')
  if has_navic and client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end
end

-- Simple servers (default config)
local simple_servers = {
  { name = 'ts_ls', binary = 'typescript-language-server' },
  { name = 'volar', binary = 'vue-language-server' },
  { name = 'tailwindcss', binary = 'tailwindcss-language-server' },
  { name = 'cssls', binary = 'css-languageserver' },
  { name = 'html', binary = 'html-languageserver' },
  { name = 'jsonls', binary = 'vscode-json-languageserver' },
  { name = 'gopls', binary = 'gopls' },
  { name = 'pyright', binary = 'pyright-langserver' },
  { name = 'svelte', binary = 'svelteserver' },
  { name = 'prismals', binary = 'prisma-language-server' },
  { name = 'dockerls', binary = 'docker-langserver' },
  { name = 'yamlls', binary = 'yaml-language-server' },
  { name = 'sqlls', binary = 'sql-language-server' },
  { name = 'graphql', binary = 'graphql-lsp' },
  { name = 'biome', binary = 'biome' },
  { name = 'dartls', binary = 'dart' },
}

for _, server in ipairs(simple_servers) do
  if has_binary(server.binary) then
    lspconfig[server.name].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })
  end
end

-- Custom servers

-- lua_ls (Neovim runtime)
if has_binary('lua-language-server') then
  lspconfig.lua_ls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
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
end

-- eslint (autofix on save)
if has_binary('vscode-eslint-language-server') then
  lspconfig.eslint.setup({
    capabilities = capabilities,
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = bufnr,
        command = 'EslintFixAll',
      })
    end,
  })
end

-- intelephense (PHP)
if has_binary('intelephense') then
  lspconfig.intelephense.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    init_options = {
      storagePath = '/tmp/intelephense',
    },
  })
end

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
  print('Open definition in (s)plit / (v)split / (t)abedit / (n)ew: ')
  local char = vim.fn.getcharstr()
  local cmd_map = { s = 'split', v = 'vsplit', t = 'tabedit', n = 'tabnew' }
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
vim.api.nvim_create_user_command('ESLintFix', 'EslintFixAll', {})
vim.api.nvim_create_user_command('Prettier', function()
  require('conform').format({ formatters = { 'prettier' }, async = true })
end, {})
vim.api.nvim_create_user_command('Format', '!npm run check', {})
vim.api.nvim_create_user_command('FormatPrisma', '!npm run format:prisma', {})
