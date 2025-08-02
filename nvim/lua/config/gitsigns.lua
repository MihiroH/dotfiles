local map = require('config.utils').map

require('gitsigns').setup {
  current_line_blame = true,
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary> (<abbrev_sha>)',
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    map('n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr=true })
    map('n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr=true })
    map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>')
    map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
    map('n', '<Leader>hS', gs.stage_buffer)
    map('n', '<Leader>hu', gs.undo_stage_hunk)
    map('n', '<Leader>hR', gs.reset_buffer)
    map('n', '<Leader>hp', gs.preview_hunk)
    map('n', '<Leader>hb', function() gs.blame_line{ full=true } end)
    map('n', '<Leader>tb', gs.toggle_current_line_blame)
    map('n', '<Leader>hd', gs.diffthis)
    map('n', '<Leader>hD', function() gs.diffthis('~') end)
    map('n', '<Leader>td', gs.toggle_deleted)
    map('n', '<Leader>gcd', ':Gcd<CR>')
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}
