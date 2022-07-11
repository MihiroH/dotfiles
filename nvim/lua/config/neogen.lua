local neogen = require 'neogen'
local map = require('config.utils').map

neogen.setup { enabled = true, jump_map = '<tab>' }
map('n', '<Leader>g', '<cmd>lua require("neogen").generate()<cr>')
map('n', '<Leader>gf', '<cmd>lua require("neogen").generate({ type = "func" })<cr>')
map('n', '<Leader>gc', '<cmd>lua require("neogen").generate({ type = "class" })<cr>')
