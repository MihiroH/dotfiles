local map = require('config.utils').map

map('x', '<Space>d', '<Plug>(textmanip-duplicate-down)')
map('n', '<Space>d', '<Plug>(textmanip-duplicate-down)')
map('x', '<Space>D', '<Plug>(textmanip-duplicate-up)')
map('n', '<Space>D', '<Plug>(textmanip-duplicate-up)')

map('x', '<C-j>', '<Plug>(textmanip-move-down)')
map('x', '<C-k>', '<Plug>(textmanip-move-up)')
map('x', '<C-h>', '<Plug>(textmanip-move-left)')
map('x', '<C-l>', '<Plug>(textmanip-move-right)')
