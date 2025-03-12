local M = {}

-- Configuration defaults
M.CONFIG = {
  autojump = true,  -- automatically jump to next conflict after choosing
}

-- Side selection constants
M.SIDES = {
  OURS = "ours",
  THEIRS = "theirs",
  ALL_THEIRS = "all_theirs",
  BOTH = "both",
  NONE = "none",
  CURSOR = "cursor",
}

-- Conflict marker constants
M.MARKERS = {
  CONFLICT_START = "^<<<<<<",
  CONFLICT_MIDDLE = "^=======",
  CONFLICT_END = "^>>>>>>>",
}

-- Highlight group names
M.HIGHLIGHTS = {
  CURRENT = "GitConflictCurrent",
  CURRENT_LABEL = "GitConflictCurrentLabel",
  INCOMING = "GitConflictIncoming",
  INCOMING_LABEL = "GitConflictIncomingLabel",
}

return M

