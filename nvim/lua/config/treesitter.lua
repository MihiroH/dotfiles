local present, ts_config = pcall(require, 'nvim-treesitter.configs')
local present_, ts_parser = pcall(require, 'nvim-treesitter.parsers')

if not present then return end
if not present_ then return end

ts_config.setup {
  ensure_installed = {
    'vim',
    'lua',

    "html",
    "javascript",
    "typescript",
    "vue",
    "tsx",
    "svelte",
    "astro",
    "prisma",
    "embedded_template", -- ejs, erb

    'dart',
    'php',
    'go',
    'gomod',
  },

  highlight = {
    enable = true,
  },

  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection    = 'gnn',
      node_incremental  = 'grn',
      scope_incremental = 'grc',
      node_decremental  = 'grm',
    },
  },

  matchup = {
    enable = true,
  },
}

vim.cmd('autocmd VimEnter,BufNewFile,BufRead *.ejs set filetype=embedded_template')
