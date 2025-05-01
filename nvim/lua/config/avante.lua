local present, avante = pcall(require, 'avante')
local present_, avante_lib = pcall(require, 'avante_lib')

if not present then return end
if not present_ then return end

avante_lib.load()
avante.setup({
  provider = 'copilot',
  -- auto_suggestions_provider = 'copilot',
  copilot = {
    model = 'claude-3.7-sonnet',
    -- model = 'claude-3.5-sonnet',
  },
  web_search_engine = {
    provider = 'tavily',
  },
  behavior = {
    -- auto_suggestions = true,
    enable_cursor_planning_mode = true,
  },
  windows = {
    ask = {
      start_insert = false,
    },
  },
  highlights = {
    diff = {
      current = 'DiffAdd',
      incoming = 'DiffChange',
    },
  },
  file_selector = {
    --- @alias FileSelectorProvider "native" | "fzf" | "mini.pick" | "snacks" | "telescope" | string | fun(params: avante.file_selector.IParams|nil): nil
    provider = 'telescope',
    -- Options override for custom providers
    provider_opts = {
      ---@param params avante.file_selector.opts.IGetFilepathsParams
      get_filepaths = function(params)
        local pwd = vim.fn.getcwd() ---@type string
        local selected_filepaths = params.selected_filepaths ---@type string[]
        local cmd = string.format("fd --base-directory '%s' --hidden --exclude .git", vim.fn.fnameescape(pwd))
        local output = vim.fn.system(cmd)
        local filepaths = vim.split(output, "\n", { trimempty = true })
        return vim
          .iter(filepaths)
          :filter(function(filepath)
            return not vim.tbl_contains(selected_filepaths, filepath)
          end)
          :totable()
      end,
      telescope_opts = TelescopeThemeOpts,
    }
  },
})

-- Key mappings
local map = require('config.utils').map
local opts = { noremap = true, silent = true }

map('n', '<leader>al', '<cmd>AvanteClear<CR>', opts)

-- Disable ESC key in Avante panel
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'Avante',
  callback = function()
    map({'n', 'o'}, '<ESC>', '<Nop>', { buffer = true })
  end
})
