local present, telescope = pcall(require, 'telescope')
local present_, tabs = pcall(require, 'telescope-tabs')

if not present then return end
if not present_ then return end

telescope.setup({
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden',
    },
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
      prefer_locations = true, -- always use Telescope locations to preview definitions/declarations/implementations etc
    },
  },
})

-- Extensions
telescope.load_extension('coc')
telescope.load_extension('frecency')
telescope.load_extension('fzy_native')
telescope.load_extension('conflicts')
telescope.load_extension('telescope-tabs')

tabs.setup()

-- Key mappings
local map = require('config.utils').map
local opts = { noremap = true, silent = true }

local layout_strategy = 'horizontal'
local layout_config = {
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
    prompt_position = "top",
    preview_cutoff = 40,
  },
}
TelescopeThemeOpts = {
  layout_strategy = layout_strategy,
  layout_config = layout_config,
}

map('n', '<Leader>.', function() require('telescope.builtin').find_files(require('telescope.themes').get_dropdown(TelescopeThemeOpts)) end, opts)
map('n', '<Leader>,', function() require('telescope.builtin').live_grep(require('telescope.themes').get_dropdown(TelescopeThemeOpts)) end, opts)
-- map('n', '<Leader>r', function() require('telescope.builtin').frecency(require('telescope.themes').get_dropdown(TelescopeThemeOpts)) end, opts)
map('n', '<Leader>bb', function() require('telescope.builtin').buffers(require('telescope.themes').get_dropdown(TelescopeThemeOpts)) end, opts)
map('n', '<Leader>fb', function() require('telescope.builtin').git_bcommits(require('telescope.themes').get_dropdown(TelescopeThemeOpts)) end, opts)
map('n', '<Leader>fs', function() require('telescope.builtin').grep_string(require('telescope.themes').get_dropdown(TelescopeThemeOpts)) end, opts)
map('n', '<Leader>fcm', function() require('telescope.builtin').commands(require('telescope.themes').get_dropdown({ layout_strategy = 'center' })) end, opts)
map('n', '<Leader>fch', function() require('telescope.builtin').command_history(require('telescope.themes').get_dropdown({ layout_strategy = 'center' })) end, opts)
map('n', '<Leader>sh', function() require('telescope.builtin').search_history(require('telescope.themes').get_dropdown({ layout_strategy = 'center' })) end, opts)
-- map('n', '<Leader>fh', function() require('telescope.builtin').help_tags(require('telescope.themes').get_dropdown(TelescopeThemeOpts)) end, opts)
-- map('n', '<Leader>fm', function() require('telescope.builtin').lsp_document_symbols(require('telescope.themes').get_dropdown(TelescopeThemeOpts)) end, opts)
map('n', '<Leader>fr', function() require('telescope').extensions.coc.references(require('telescope.themes').get_dropdown(TelescopeThemeOpts)) end, opts)
map('n', '<Leader>fd', function() require('telescope').extensions.coc.diagnostics(require('telescope.themes').get_dropdown(TelescopeThemeOpts)) end, opts)
map('n', '<Leader>fa', function() require('telescope').extensions.coc.file_code_actions(require('telescope.themes').get_dropdown(TelescopeThemeOpts)) end, opts)
map('n', '<Leader>tl', function() require('telescope-tabs').list_tabs(require('telescope.themes').get_dropdown({ layout_strategy = 'center' })) end, opts)
map('n', '<Leader>fgc', function()
  local conf = vim.tbl_extend('force', TelescopeThemeOpts, {
    git_command = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden',
      '-l',
      '<<<<<<<',
    },
  })
  require('telescope').extensions.conflicts.conflicts(require('telescope.themes').get_dropdown(conf))
end, opts)
