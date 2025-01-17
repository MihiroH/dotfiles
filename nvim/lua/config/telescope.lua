local present, telescope = pcall(require, 'telescope')

if not present then return end

telescope.setup {
  defaults = {
    theme = 'dropdown',
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        width = 0.95,
        height = 0.95,
        prompt_position = "top",
        preview_cutoff = 120,
      },
      vertical = {
        width = 0.95,
        height = 0.95,
        prompt_position = "top",
        preview_cutoff = 40,
      },
      center = {
        width = 0.5,
        height = 0.4,
        preview_cutoff = 40,
        prompt_position = "top",
      },
      cursor = {
        width = 0.8,
        height = 0.9,
        preview_cutoff = 40,
      },
      bottom_pane = {
        height = 25,
        prompt_position = "top",
        preview_cutoff = 120,
      },
    },
    -- scroll_strategy = 'cycle',
    file_ignore_patterns = {
      'node_modules',
      '.git',
      'package-lock.json',
      'yarn.lock',
      'composer.lock',
      'vendor',
      '*.min.*',
    },
  },
  file_sorter = require('telescope.sorters').get_fzy_sorter,
  generic_sorter = require('telescope.sorters').get_fzy_sorter,
  extensions = {
    frecency = {
      workspaces = {
        exo = '/home/wil/projects/research/exoplanet'
      }
    },
    coc = {
      -- theme = 'dropdown',
      prefer_locations = true, -- always use Telescope locations to preview definitions/declarations/implementations etc
    },
  },
  -- layout_config = {
  --   width = 0.95,
  --   height = 0.95,
  --   preview_cutoff = 120,
  -- },
}

-- Extensions
telescope.load_extension('coc')
telescope.load_extension 'frecency'
telescope.load_extension 'fzy_native'

local theme_opts = '{ layout_strategy = "horizontal", layout_config = { horizontal = { width = 0.95, height = 0.95, prompt_position = "top", preview_cutoff = 120, }, vertical = { width = 0.95, height = 0.95, prompt_position = "top", preview_cutoff = 40, }, center = { width = 0.5, height = 0.4, preview_cutoff = 40, prompt_position = "top", }, cursor = { width = 0.8, height = 0.9, preview_cutoff = 40, }, bottom_pane = { height = 25, prompt_position = "top", preview_cutoff = 120, }, } }'

-- Key mappings
local map = require('config.utils').map
local opts = { noremap = true, silent = true }

map('n', '<Leader>.', ':lua require"telescope.builtin".find_files(require("telescope.themes").get_dropdown(' .. theme_opts .. '))<CR>', opts)
map('n', '<Leader>,', ':lua require"telescope.builtin".live_grep(require("telescope.themes").get_dropdown(' .. theme_opts .. '))<CR>', opts)
-- map('n', '<Leader>r', ':lua require"telescope.builtin".frecency(require("telescope.themes").get_dropdown(' .. theme_opts .. '))<CR>', opts)
map('n', '<Leader>bb', ':lua require"telescope.builtin".buffers(require("telescope.themes").get_dropdown(' .. theme_opts .. '))<CR>', opts)
map('n', '<Leader>fb', ':lua require"telescope.builtin".git_bcommits(require("telescope.themes").get_dropdown(' .. theme_opts .. '))<CR>', opts)
map('n', '<Leader>fs', ':lua require"telescope.builtin".grep_string(require("telescope.themes").get_dropdown(' .. theme_opts .. '))<CR>', opts)
map('n', '<Leader>fh', ':lua require"telescope.builtin".help_tags(require("telescope.themes").get_dropdown(' .. theme_opts .. '))<CR>', opts)
map('n', '<Leader>fr', ':Telescope coc references<CR>', opts)
map('n', '<Leader>fd', ':Telescope coc diagnostics<CR>', opts)
map('n', '<Leader>fa', ':Telescope coc file_code_actions<CR>', opts)

-- map('n', '<Leader>.', ':Telescope find_files<CR>', opts)
-- map('n', '<Leader>,', ':Telescope live_grep<CR>', opts)
-- map('n', '<Leader>r', ':Telescope frecency<CR>', opts)
-- map('n', '<Leader>bb', ':Telescope buffers<CR>', opts)
-- map('n', '<Leader>fb', ':Telescope git_bcommits<CR>', opts)
-- map('n', '<Leader>fs', ':Telescope grep_string<CR>', opts)
-- map('n', '<Leader>fh', ':Telescope help_tags<CR>', opts)
