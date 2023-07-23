local present, telescope = pcall(require, 'telescope')

if not present then return end

telescope.setup {
  defaults = {
    layout_strategy = 'flex',
    scroll_strategy = 'cycle',
    file_ignore_patterns = {
      'node_modules/.*',
      '.git/.*',
      'package-lock.json'
    }
  },
  file_sorter = require('telescope.sorters').get_fzy_sorter,
  generic_sorter = require('telescope.sorters').get_fzy_sorter,
  extensions = { frecency = { workspaces = { exo = '/home/wil/projects/research/exoplanet' } } },
  layout_config = {
    width = 0.85,
    height = 0.95,
    preview_cutoff = 120,
  },
}

-- Extensions
telescope.load_extension 'frecency'
telescope.load_extension 'fzy_native'

-- Key mappings
local map = require('config.utils').map
local opts = { noremap = true, silent = true }

map('n', '<Leader>.', ':Telescope find_files hidden=true theme=get_dropdown<CR>', opts)
map('n', '<Leader>,', ':Telescope live_grep theme=get_dropdown<CR>', opts)
map('n', '<Leader>r', ':Telescope frecency theme=get_dropdown<CR>', opts)
map('n', '<Leader>bb', ':Telescope buffers theme=get_dropdown<CR>', opts)
map('n', '<Leader>fb', ':Telescope git_bcommits theme=get_dropdown<CR>', opts)
map('n', '<Leader>fs', ':Telescope grep_string theme=get_dropdown<CR>', opts)
map('n', '<Leader>fh', ':Telescope help_tags theme=get_dropdown<CR>', opts)
