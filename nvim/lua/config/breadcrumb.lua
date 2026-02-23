local present, dropbar_api = pcall(require, 'dropbar.api')

if not present then return end

local map = require('config.utils').map
local opts = { noremap = true, silent = true }

map('n', '<Leader>;', dropbar_api.pick, opts)
map('n', '[;', dropbar_api.goto_context_start, opts)
map('n', '];', dropbar_api.select_next_context, opts)
