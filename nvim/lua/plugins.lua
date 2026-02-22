return {
  -- file explorer
  {
    'stevearc/oil.nvim',
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
    build = ':TSUpdate',
    config = function() require('config.treesitter') end,
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
    version = '*',
    config = function() require('config.surround') end,
  },

  -- Coc (Language Server Protocol)
  {
    'neoclide/coc.nvim',
    commit = 'd1fc170',
    config = function() require('config.coc') end,
  },

  -- A code outline window for skimming and quick navigation
  {
    'stevearc/aerial.nvim',
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
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-frecency.nvim',
      'nvim-telescope/telescope-fzy-native.nvim',
      'fannheyward/telescope-coc.nvim',
      'Snikimonkd/telescope-git-conflicts.nvim',
      'LukasPietzschmann/telescope-tabs',
    },
    config = function() require('config.telescope') end,
  },
  {
    'nvim-telescope/telescope-frecency.nvim',
    dependencies = { 'kkharji/sqlite.lua' },
  },
  { 'nvim-telescope/telescope-fzy-native.nvim' },

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
