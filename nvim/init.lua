--
--  _  _ ___ _____   _____ __  __
-- | \| | __/ _ \ \ / /_ _|  \/  |
-- | .` | _| (_) \ V / | || |\/| |
-- |_|\_|___\___/ \_/ |___|_|  |_|
--

local fn = vim.fn

-- basic config
require('basic')

-- init neovim-only configs
require('gconfig')

-- lazy.nvim bootstrap
local lazypath = fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- init plugins
require('lazy').setup(require('plugins'))
