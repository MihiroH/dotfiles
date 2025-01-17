-- Install packer if does not exist
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

local present
local packer

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system {
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    install_path
  }

  vim.cmd('packadd packer.nvim')

  present, packer = pcall(require, 'packer')

  if present then
    print 'Packer cloned successfully.'
  else
    error(string.format(
      "Couldn't clone packer!\nPacker path: %s\n%s",
      install_path,
      packer
    ))

    return
  end
end

-- Regenerate compiled loader file on file save
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

-- load plugins
packer = packer or require('packer')

return packer.startup(function(use)
  -- yo dawg, I heard you like plugin managers
  use {'wbthomason/packer.nvim', opt = true}

  -- icon
  use 'lambdalisue/nerdfont.vim'

  -- fern renderer icon
  use {
    'lambdalisue/fern-renderer-nerdfont.vim',
    'lambdalisue/glyph-palette.vim',
    requires = { 'lambdalisue/nerdfont.vim' }
  }

  -- fern.vim
  use {
    'lambdalisue/fern.vim',
    branch = 'main',
    config = function() require('config.fern') end,
  }

  -- fern hijack
  use {
    'lambdalisue/fern-hijack.vim',
    requires = { 'lambdalisue/fern.vim', opt = true },
  }

  -- color scheme
  use {
    -- 'sonph/onehalf',
    'navarasu/onedark.nvim',
    -- rtp = 'vim/',
    config = function() require('config.colors') end,
  }

  -- indent
  use {
    'lukas-reineke/indent-blankline.nvim',
    config = function() require('config.indent') end,
  }

  -- Preview colors of hexcodes
  use {
    'norcalli/nvim-colorizer.lua',
    event = 'VimEnter',
    config = function () require('colorizer').setup() end,
  }

  -- Emmet
  use {
    'mattn/emmet-vim',
    ft = { 'html', 'css', 'javascriptreact', 'typescriptreact', 'jst', 'scss', 'sass', 'embedded_template' },
    config = function() require('config.emmet') end,
  }

  -- text move, duplication
  use {
    't9md/vim-textmanip',
    config = function() require('config.textmanip') end,
  }

  -- Better syntax highlighting
  use {
    'nvim-treesitter/nvim-treesitter',
    -- commit = 'ddcda043017f34fa1a8109fcb847e5dfdd70ee41',
    run = ':TSUpdate',
    config = function () require('config.treesitter') end,
  }

  -- Show code context
  -- use 'nvim-treesitter/nvim-treesitter-context'

  -- Documentation
  use {
    'danymat/neogen',
    requires = 'nvim-treesitter',
    config = function () require('config.neogen') end,
  }

  -- comments
  use {
    'numToStr/Comment.nvim',
    config = function() require('config.comment') end,
  }

  -- surround motions
  use {
    'kylechui/nvim-surround',
    version = '*',
    config = function () require('config.surround') end,
  }

  -- coc
  use {
    'neoclide/coc.nvim',
    branch = 'release',
    config = function() require('config.coc') end,
  }

  -- GitHub copilot
  use {
    'github/copilot.vim',
    config = function() require('config.copilot') end,
  }

  -- Search
  use {
    {
      'nvim-telescope/telescope.nvim',
      -- tag = '0.1.5',
      branch = '0.1.x',
      requires = {
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim',
        'telescope-frecency.nvim',
        'telescope-fzy-native.nvim',
        'fannheyward/telescope-coc.nvim'
      },
      wants = {
        'popup.nvim',
        'plenary.nvim',
        'telescope-frecency.nvim',
        'telescope-fzy-native.nvim',
      },
      config = function() require('config.telescope') end,
      -- cmd = 'Telescope',
      -- module = 'telescope',
    },
    {
      'nvim-telescope/telescope-frecency.nvim',
      -- after = 'telescope.nvim',
      requires = { 'tami5/sqlite.lua' },
    },
    {
      'nvim-telescope/telescope-fzy-native.nvim',
      -- run = 'make',
    },
  }

  -- Git
  use {
    { 'tpope/vim-fugitive' },
    {
      'lewis6991/gitsigns.nvim',
      requires = { 'nvim-lua/plenary.nvim' },
      config = function () require('config.gitsigns') end,
    },
  }

  -- syntax checking
  use {
    'w0rp/ale',
    config = function () require('config.ale') end,
  }

  -- Pretty symbols
  use {
    'kyazdani42/nvim-web-devicons',
    config = function() require('nvim-web-devicons').setup() end,
  }

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    config = function() require('config.lualine') end,
  }

  -- git conflict markers
  use 'rhysd/conflict-marker.vim'

  -- editor config
  use {
    'editorconfig/editorconfig-vim',
    event = 'InsertEnter *',
  }

  -- Run your favorite search tool from Vim
  use {
    'mileszs/ack.vim',
    config = function() require('config.ack') end,
  }

  -- Modifiable within quickfix
  use 'stefandtw/quickfix-reflector.vim'

  -- GUI Git Operator
  use {
    'kdheepak/lazygit.nvim',
    config = function() require('config.lazygit') end,
  }

  -- Generate image of the source code
  use {
    'segeljakt/vim-silicon',
    cmd = 'Silicon',
    config = function() require('config.silicon') end,
  }

  -- Highlight, navigate, and operate on sets of matching text
  -- use 'andymass/vim-matchup'

  -- Execute commands
  use {
    'thinca/vim-quickrun',
    ft = { 'python', 'php', 'javascript', 'go' },
    config = function() require('config.quickrun') end,
  }

  -- Asynchronous execution library
  use {
    'Shougo/vimproc.vim',
    ft = { 'python', 'php', 'javascript', 'go' },
    run = 'make',
    config = function() require('config.quickrun') end,
  }

  -- Test
  use {
    'vim-test/vim-test',
    ft = { 'python', 'php', 'javascript', 'go' },
    config = function() require('config.test') end,
  }

  -- Visualizing test coverage results
  use({
    'andythigpen/nvim-coverage',
    requires = 'nvim-lua/plenary.nvim',
    config = function() require('config.coverage') end,
  })

  -- Live Share
  use({
    'jbyuki/instant.nvim',
    config = function() require('config.liveshare') end,
  })

  -- Translator
  use({
    'voldikss/vim-translator',
    config = function() require('config.translator') end,
  })

  use({
    'utilyre/barbecue.nvim',
    tag = "*",
    requires = {
      'SmiteshP/nvim-navic',
      'kyazdani42/nvim-web-devicons',
      'neovim/nvim-lspconfig',
    },
    after = 'nvim-web-devicons', -- keep this if you're using NvChad
    config = function() require('config.navic') end,
  })
end)
