local Constants = require("config.git-conflict-constants")
local SIDES = Constants.SIDES
local M = {}

M.DEFAULT_KEYMAPS = {
  choose = {
    [SIDES.OURS] = "co",
    [SIDES.THEIRS] = "ct",
    [SIDES.ALL_THEIRS] = "ca",
    [SIDES.NONE] = "c0",
    [SIDES.BOTH] = "cb",
    [SIDES.CURSOR] = "cc",
  },
  next = "]x",
  prev = "[x",
}

function M.setup_keymaps(bufnr, actions)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- Choose sides
  vim.keymap.set("n", M.DEFAULT_KEYMAPS.choose[SIDES.OURS], function() actions.choose_side(SIDES.OURS) end, opts)
  vim.keymap.set("n", M.DEFAULT_KEYMAPS.choose[SIDES.THEIRS], function() actions.choose_side(SIDES.THEIRS) end, opts)
  vim.keymap.set("n", M.DEFAULT_KEYMAPS.choose[SIDES.ALL_THEIRS], function() actions.choose_side(SIDES.ALL_THEIRS) end, opts)
  vim.keymap.set("n", M.DEFAULT_KEYMAPS.choose[SIDES.NONE], function() actions.choose_side(SIDES.NONE) end, opts)
  vim.keymap.set("n", M.DEFAULT_KEYMAPS.choose[SIDES.BOTH], function() actions.choose_side(SIDES.BOTH) end, opts)
  vim.keymap.set("n", M.DEFAULT_KEYMAPS.choose[SIDES.CURSOR], function() actions.choose_side(SIDES.CURSOR) end, opts)

  -- Navigation
  vim.keymap.set("n", M.DEFAULT_KEYMAPS.next, function() actions.next_conflict() end, opts)
  vim.keymap.set("n", M.DEFAULT_KEYMAPS.prev, function() actions.prev_conflict() end, opts)
end

return M

