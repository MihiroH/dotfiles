local api = vim.api
local bit = require("bit")
local rshift, band = bit.rshift, bit.band
local Actions = require("config.git-conflict-actions")
local Keymaps = require("config.git-conflict-keymaps")
local Constants = require("config.git-conflict-constants")
local MARKERS = Constants.MARKERS
local HIGHLIGHTS = Constants.HIGHLIGHTS

--- helper
local H = {}

-- Module
local M = {}

-- Constants
local NAMESPACE = api.nvim_create_namespace("git-conflict-highlight")

local PRIORITY = vim.highlight.priorities.user

-- Highlight definitions
local Highlights = {
  CURRENT = {
    name = HIGHLIGHTS.CURRENT,
    link = "DiffAdd",
    default = true,
  },
  CURRENT_LABEL = {
    name = HIGHLIGHTS.CURRENT_LABEL,
    shade_link = HIGHLIGHTS.CURRENT,
    shade = 30,
    default = true,
  },
  INCOMING = {
    name = HIGHLIGHTS.INCOMING,
    link = "DiffChange",
    default = true,
  },
  INCOMING_LABEL = {
    name = HIGHLIGHTS.INCOMING_LABEL,
    shade_link = HIGHLIGHTS.INCOMING,
    shade = 30,
    default = true,
  },
}

-- Check if highlight group has colors set
local function has_set_colors(hl_group)
  local hl = api.nvim_get_hl(0, { name = hl_group })
  return next(hl) ~= nil
end

-- Create highlights
local function setup_highlights()
  -- vim.api.nvim_set_hl(0, "GitConflictCurrent", { link = "DiffAdd" })
  -- vim.api.nvim_set_hl(0, "GitConflictCurrentLabel", { bg = "#2e4c42", fg = "#9add89" })
  -- vim.api.nvim_set_hl(0, "GitConflictIncoming", { link = "DiffChange" })
  -- vim.api.nvim_set_hl(0, "GitConflictIncomingLabel", { bg = "#363a5e", fg = "#a2bbff" })

  ---@return number | nil
  local function get_bg(hl_name)
    local hl = api.nvim_get_hl(0, { name = hl_name })
    -- If link is specified, get the color from the linked highlight group
    if hl.link then
      return get_bg(hl.link)
    end
    return hl.bg
  end

  vim.iter(Highlights):each(function(_, hl)
    if has_set_colors(hl.name) then return end

    if hl.shade_link == nil or hl.shade == nil then
      api.nvim_set_hl(
        0,
        hl.name,
        { fg = hl.fg or nil, bg = hl.bg or nil, link = hl.link or nil, bold = hl.bold, default = hl.default }
      )
      return
    end

    local bg
    local bold = hl.bold

    local link_bg = get_bg(hl.shade_link)
    if link_bg == nil then
      -- TODO: log this
      -- vim.notify(string.format("highlights %s don't have bg, use fallback", hl.shade_link), vim.log.levels.INFO)
      link_bg = 3229523
    end

    bg = H.shade_color(link_bg, hl.shade)

    api.nvim_set_hl(0, hl.name, { bg = bg, bold = bold, default = hl.default })
  end)
end

-- Cache for buffers with conflicts
local buffer_cache = {}

-- Check if buffer is valid
local function is_valid_buf(bufnr)
  return api.nvim_buf_is_valid(bufnr) and api.nvim_buf_get_option(bufnr, "buflisted")
end

-- Get buffer lines
local function get_buf_lines(start_line, end_line, bufnr)
  bufnr = bufnr or 0
  return api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
end

-- Highlight a range of lines in the buffer
local function highlight_range(bufnr, hl, range_start, range_end)
  if not range_start or not range_end then return end

  return api.nvim_buf_set_extmark(bufnr, NAMESPACE, range_start, 0, {
    hl_group = hl,
    hl_eol = true,
    hl_mode = "combine",
    end_row = range_end,
    priority = PRIORITY,
  })
end

-- Add a section label (e.g., "<<<<<<< HEAD (Current changes)")
local function draw_section_label(bufnr, hl_group, label, lnum)
  local remaining_space = api.nvim_win_get_width(0) - api.nvim_strwidth(label)
  return api.nvim_buf_set_extmark(bufnr, NAMESPACE, lnum, 0, {
    hl_group = hl_group,
    virt_text = { { label .. string.rep(" ", remaining_space), hl_group } },
    virt_text_pos = "overlay",
    priority = PRIORITY,
  })
end

-- Detect conflicts in buffer content
local function detect_conflicts(lines)
  local positions = {}
  local position = nil
  local has_middle = false

  for index, line in ipairs(lines) do
    local lnum = index - 1

    if line:match(MARKERS.CONFLICT_START) then
      position = {
        current = { range_start = lnum, content_start = lnum + 1 },
        middle = {},
        incoming = {},
      }
    end

    if position ~= nil and line:match(MARKERS.CONFLICT_MIDDLE) then
      has_middle = true
      position.current.range_end = lnum - 1
      position.current.content_end = lnum - 1
      position.middle.range_start = lnum
      position.middle.range_end = lnum
      position.incoming.range_start = lnum + 1
      position.incoming.content_start = lnum + 1
    end

    if position ~= nil and has_middle and line:match(MARKERS.CONFLICT_END) then
      position.incoming.range_end = lnum
      position.incoming.content_end = lnum - 1
      positions[#positions + 1] = position

      position, has_middle = nil, false
    end
  end

  return #positions > 0, positions
end

-- Apply highlighting to conflict markers and sections
local function highlight_conflicts(bufnr, positions, lines)
  if not positions or vim.tbl_isempty(positions) then return end

  M.clear_highlights(bufnr)

  for _, position in ipairs(positions) do
    local current_start = position.current.range_start
    local current_end = position.current.range_end
    local incoming_start = position.incoming.range_start
    local incoming_end = position.incoming.range_end

    -- Add one since the index access in lines is 1 based
    local current_label = lines[current_start + 1] .. " (Current changes)"
    local incoming_label = lines[incoming_end + 1] .. " (Incoming changes)"

    -- Highlight current/ours section
    draw_section_label(bufnr, "GitConflictCurrentLabel", current_label, current_start)
    highlight_range(bufnr, "GitConflictCurrent", current_start, current_end + 1)

    -- Highlight incoming/theirs section
    highlight_range(bufnr, "GitConflictIncoming", incoming_start, incoming_end + 1)
    draw_section_label(bufnr, "GitConflictIncomingLabel", incoming_label, incoming_end)
  end

  -- Store positions in buffer cache
  buffer_cache[bufnr] = {
    positions = positions,
    tick = vim.b[bufnr].changedtick,
  }
end

-- Navigate to next conflict
function M.next_conflict()
  Actions.next_conflict(buffer_cache)
end

-- Navigate to previous conflict
function M.prev_conflict()
  Actions.prev_conflict(buffer_cache)
end

-- Choose a side of the conflict
---@param side string One of "ours", "theirs", "all_theirs", "both", "none", "cursor"
function M.choose_side(side)
  Actions.choose_side(side, buffer_cache, M.parse_buffer, M.clear_highlights)
end

-- Parse buffer for conflict markers
function M.parse_buffer(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()

  if not is_valid_buf(bufnr) then return end

  -- If the buffer has not changed since the last check, skip processing
  if buffer_cache[bufnr] and buffer_cache[bufnr].tick == vim.b[bufnr].changedtick then
    return
  end

  local lines = get_buf_lines(0, -1, bufnr)
  local has_conflict, positions = detect_conflicts(lines)

  if has_conflict then
    highlight_conflicts(bufnr, positions, lines)
    vim.api.nvim_exec_autocmds("User", { pattern = "GitConflictDetected", data = { bufnr = bufnr } })
  else
    M.clear_highlights(bufnr)
    vim.api.nvim_exec_autocmds("User", { pattern = "GitConflictResolved", data = { bufnr = bufnr } })
    buffer_cache[bufnr] = nil
  end

  return has_conflict
end

-- Clear highlights in a buffer
function M.clear_highlights(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  if not api.nvim_buf_is_valid(bufnr) then return end

  api.nvim_buf_clear_namespace(bufnr, NAMESPACE, 0, -1)
end

--- Returns a table containing the RGB values encoded inside 24 least
--- significant bits of the number @rgb_24bit
---
---@param rgb_24bit number 24-bit RGB value
---@return {r: integer, g: integer, b: integer} with keys 'r', 'g', 'b' in [0,255]
function H.decode_24bit_rgb(rgb_24bit)
  vim.validate({ rgb_24bit = { rgb_24bit, "n", true } })
  local r = band(rshift(rgb_24bit, 16), 255)
  local g = band(rshift(rgb_24bit, 8), 255)
  local b = band(rgb_24bit, 255)
  return { r = r, g = g, b = b }
end

---@param attr integer
---@param percent integer
function H.alter(attr, percent) return math.floor(attr * (100 + percent) / 100) end

---@source https://stackoverflow.com/q/5560248
---@see https://stackoverflow.com/a/37797380
---Lighten a specified hex color
---@param color number
---@param percent number
---@return string
function H.shade_color(color, percent)
  percent = vim.opt.background:get() == "light" and percent / 5 or percent
  local rgb = H.decode_24bit_rgb(color)
  if not rgb.r or not rgb.g or not rgb.b then return "NONE" end
  local r, g, b = H.alter(rgb.r, percent), H.alter(rgb.g, percent), H.alter(rgb.b, percent)
  r, g, b = math.min(r, 255), math.min(g, 255), math.min(b, 255)
  return string.format("#%02x%02x%02x", r, g, b)
end

-- Count conflicts in a buffer
function M.conflict_count(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()

  if not buffer_cache[bufnr] or not buffer_cache[bufnr].positions then
    return 0
  end

  return #buffer_cache[bufnr].positions
end

-- Setup the plugin
-- Setup keymaps for the buffer
local function setup_keymaps(bufnr)
  local actions = {
    next_conflict = M.next_conflict,
    prev_conflict = M.prev_conflict,
    choose_side = M.choose_side,
  }
  Keymaps.setup_keymaps(bufnr, actions)
end

function M.setup()
  local augroup = api.nvim_create_augroup("GitConflictHighlight", { clear = true })

  -- Create highlights and ensure they are maintained
  setup_highlights()

  -- Ensure highlights are recreated when colorscheme changes
  api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = setup_highlights,
  })

  -- Auto detect conflicts on buffer read/write
  api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    group = augroup,
    callback = function(ev)
      M.parse_buffer(ev.buf)
      if M.conflict_count(ev.buf) > 0 then
        setup_keymaps(ev.buf)
        -- Jump to first conflict when opening file
        if Constants.CONFIG.autojump then
          vim.schedule(function()
            Actions.next_conflict(buffer_cache)
            vim.cmd([[normal! zz]])
          end)
        end
      end
    end
  })

  -- Update conflict markers on buffer write
  api.nvim_create_autocmd({"BufWritePost"}, {
    group = augroup,
    callback = function(ev)
      M.parse_buffer(ev.buf)
      if M.conflict_count(ev.buf) > 0 then
        setup_keymaps(ev.buf)
      end
    end
  })

  -- Check for conflicts when window is entered or cursor moves
  api.nvim_create_autocmd({"WinEnter", "CursorHold"}, {
    group = augroup,
    callback = function(ev)
      M.parse_buffer(ev.buf)
    end
  })

  -- Add decoration provider to handle updates when the buffer is displayed
  api.nvim_set_decoration_provider(NAMESPACE, {
    on_buf = function(_, bufnr, _)
      return is_valid_buf(bufnr)
    end,
    on_win = function(_, _, bufnr, _, _)
      M.parse_buffer(bufnr)
    end,
  })
end

return M
