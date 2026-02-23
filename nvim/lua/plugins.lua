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
    event = 'VeryLazy',
    config = function() require('config.indent') end,
  },

  -- Preview colors of hexcodes
  {
    'norcalli/nvim-colorizer.lua',
    event = 'VeryLazy',
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
    event = 'VeryLazy',
    config = function() require('config.textmanip') end,
  },

  -- Better syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    config = function() require('config.treesitter')
    end,
  },

  -- comments
  {
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
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
    event = 'BufReadPost',
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
    event = 'VeryLazy',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons'
    },
    config = function() require('config.aerial') end,
  },

  -- GitHub copilot
  {
    'github/copilot.vim',
    event = 'InsertEnter',
    config = function() require('config.copilot') end,
  },

  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && bun install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  },

  {
    'hat0uma/csvview.nvim',
    ft = { 'csv', 'tsv' },
    config = function() require('config.csvview') end,
  },

  -- Search
  {
    'nvim-telescope/telescope.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'Snikimonkd/telescope-git-conflicts.nvim',
      'LukasPietzschmann/telescope-tabs',
      'nvim-telescope/telescope-ui-select.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function() require('config.telescope') end,
  },

  -- Git
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'Gcd', 'Gdiffsplit', 'Gvdiffsplit', 'Gread', 'Gwrite' },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPost',
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
    lazy = true,
    config = function() require('nvim-web-devicons').setup() end,
  },

  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function() require('config.lualine') end,
  },

  -- Modifiable within quickfix
  {
    'stefandtw/quickfix-reflector.vim',
    ft = 'qf',
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
    cmd = { 'Coverage', 'CoverageLoad', 'CoverageShow', 'CoverageHide', 'CoverageToggle', 'CoverageSummary' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function() require('config.coverage') end,
  },

  -- Translator
  {
    'voldikss/vim-translator',
    event = 'VeryLazy',
    config = function() require('config.translator') end,
  },
}
