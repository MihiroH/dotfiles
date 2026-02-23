return {
  -- file explorer
  {
    'stevearc/oil.nvim',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function() require('config.oil') end,
  },

  -- color scheme
  {
    'sainnhe/everforest',
    priority = 1000,
    config = function() require('config.colors') end,
  },

  -- indent
  {
    'lukas-reineke/indent-blankline.nvim',
    config = function() require('config.indent') end,
  },

  -- Preview colors of hexcodes
  {
    'norcalli/nvim-colorizer.lua',
    event = 'VimEnter',
    config = function() require('colorizer').setup() end,
  },

  -- Emmet
  {
    'mattn/emmet-vim',
    ft = { 'html', 'css', 'javascriptreact', 'typescriptreact', 'jst', 'scss', 'sass', 'embedded_template' },
    config = function() require('config.emmet') end,
  },

  -- text move, duplication
  {
    't9md/vim-textmanip',
    config = function() require('config.textmanip') end,
  },

  -- Better syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
  },

  -- Documentation
  {
    'danymat/neogen',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function() require('config.neogen') end,
  },

  -- comments
  {
    'numToStr/Comment.nvim',
    config = function() require('config.comment') end,
  },

  -- surround motions
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    config = function() require('config.surround') end,
  },

  -- Completion engine
  {
    'saghen/blink.cmp',
    version = '1.*',
    config = function() require('config.cmp') end,
  },

  -- LSP
  {
    'mason-org/mason-lspconfig.nvim',
    opts = {},
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'neovim/nvim-lspconfig',
      'saghen/blink.cmp',
    },
    config = function() require('config.lsp') end,
  },

  -- Auto-pairs (replaces coc-pairs)
  -- {
  --   'windwp/nvim-autopairs',
  --   event = 'InsertEnter',
  --   config = function() require('nvim-autopairs').setup() end,
  -- },

  -- Breadcrumb navigation
  {
    'Bekaboo/dropbar.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
      },
    },
    config = function() require('config.breadcrumb') end
  },

  -- A code outline window for skimming and quick navigation
  {
    'stevearc/aerial.nvim',
    opts = {},
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons'
    },
    config = function() require('config.aerial') end,
  },

  -- GitHub copilot
  {
    'github/copilot.vim',
    config = function() require('config.copilot') end,
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    config = function() require('config.render-markdown') end,
  },

  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = function() vim.fn['mkdp#util#install']() end,
    config = function() require('config.markdown-preview') end,
  },

  {
    'hat0uma/csvview.nvim',
    config = function() require('config.csvview') end,
  },

  -- Search
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'Snikimonkd/telescope-git-conflicts.nvim',
      'LukasPietzschmann/telescope-tabs',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function() require('config.telescope') end,
  },

  -- Git
  { 'tpope/vim-fugitive' },
  {
    'lewis6991/gitsigns.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function() require('config.gitsigns') end,
  },

  -- formatting
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    config = function() require('config.conform') end,
  },

  -- linting
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function() require('config.lint') end,
  },

  -- Pretty symbols
  {
    'nvim-tree/nvim-web-devicons',
    config = function() require('nvim-web-devicons').setup() end,
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function() require('config.lualine') end,
  },

  -- Modifiable within quickfix
  { 'stefandtw/quickfix-reflector.vim' },

  -- GUI Git Operator
  {
    'kdheepak/lazygit.nvim',
    config = function() require('config.lazygit') end,
  },

  -- Generate image of the source code
  {
    'segeljakt/vim-silicon',
    cmd = 'Silicon',
    config = function() require('config.silicon') end,
  },

  -- Test
  {
    'vim-test/vim-test',
    ft = { 'python', 'php', 'javascript', 'go' },
    config = function() require('config.test') end,
  },

  -- Visualizing test coverage results
  {
    'andythigpen/nvim-coverage',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function() require('config.coverage') end,
  },

  -- Live Share
  {
    'jbyuki/instant.nvim',
    config = function() require('config.liveshare') end,
  },

  -- Translator
  {
    'voldikss/vim-translator',
    config = function() require('config.translator') end,
  },
}
