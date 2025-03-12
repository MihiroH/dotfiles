local api = vim.api
local Constants = require("config.git-conflict-constants")
local SIDES = Constants.SIDES

local M = {}

-- Get buffer lines
local function get_buf_lines(start_line, end_line, bufnr)
  bufnr = bufnr or 0
  return api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
end

-- Navigate to next conflict
function M.next_conflict(buffer_cache)
  local bufnr = api.nvim_get_current_buf()
  local cur_line = api.nvim_win_get_cursor(0)[1] - 1

  if not buffer_cache[bufnr] or not buffer_cache[bufnr].positions then return end

  for _, position in ipairs(buffer_cache[bufnr].positions) do
    if position.current.range_start > cur_line then
      api.nvim_win_set_cursor(0, {position.current.range_start + 1, 0})
      return
    end
  end
end

-- Navigate to previous conflict
function M.prev_conflict(buffer_cache)
  local bufnr = api.nvim_get_current_buf()
  local cur_line = api.nvim_win_get_cursor(0)[1] - 1

  if not buffer_cache[bufnr] or not buffer_cache[bufnr].positions then return end

  for i = #buffer_cache[bufnr].positions, 1, -1 do
    local position = buffer_cache[bufnr].positions[i]
    if position.current.range_start < cur_line then
      api.nvim_win_set_cursor(0, {position.current.range_start + 1, 0})
      return
    end
  end
end

-- Choose a side of the conflict
function M.choose_side(side, buffer_cache, parse_buffer, clear_highlights)
  local bufnr = api.nvim_get_current_buf()
  local cur_line = api.nvim_win_get_cursor(0)[1] - 1

  if not buffer_cache[bufnr] or not buffer_cache[bufnr].positions then return end

  local current_position
  for _, position in ipairs(buffer_cache[bufnr].positions) do
    if cur_line >= position.current.range_start and cur_line <= position.incoming.range_end then
      current_position = position
      break
    end
  end

  if not current_position then return end

  local lines = {}
  if side == SIDES.OURS then
    lines = get_buf_lines(current_position.current.content_start, current_position.current.content_end + 1)
  elseif side == SIDES.THEIRS or side == SIDES.ALL_THEIRS then
    lines = get_buf_lines(current_position.incoming.content_start, current_position.incoming.content_end + 1)
  elseif side == SIDES.BOTH then
    local first = get_buf_lines(current_position.current.content_start, current_position.current.content_end + 1)
    local second = get_buf_lines(current_position.incoming.content_start, current_position.incoming.content_end + 1)
    lines = vim.list_extend(first, second)
  elseif side == SIDES.NONE then
    lines = {}
    print("Choosing side.none: ", buffer_cache)
  elseif side == SIDES.CURSOR then
    if cur_line >= current_position.current.content_start and cur_line <= current_position.current.content_end then
      lines = get_buf_lines(current_position.current.content_start, current_position.current.content_end + 1)
    elseif cur_line >= current_position.incoming.content_start and cur_line <= current_position.incoming.content_end then
      lines = get_buf_lines(current_position.incoming.content_start, current_position.incoming.content_end + 1)
    end
  end

  local start_line = current_position.current.range_start
  local end_line = current_position.incoming.range_end + 1

  api.nvim_buf_set_lines(bufnr, start_line, end_line, false, lines)
  clear_highlights(bufnr)
  parse_buffer(bufnr)

  -- Handle autojump after choosing a side
  if Constants.CONFIG.autojump and side ~= SIDES.ALL_THEIRS then
    -- Use deferred execution to ensure the buffer is updated first
    vim.schedule(function()
      M.next_conflict(buffer_cache)
      vim.cmd([[normal! zz]])
    end)
  end

  if side == SIDES.ALL_THEIRS then
    -- Resolve all remaining conflicts in the buffer as "theirs"
    for _, pos in ipairs(buffer_cache[bufnr].positions) do
      if pos.current.range_start > current_position.current.range_start then
        -- Get the lines for this conflict
        local conflict_lines = get_buf_lines(pos.incoming.content_start, pos.incoming.content_end + 1)
        -- Replace the entire conflict with the incoming changes
        api.nvim_buf_set_lines(bufnr, pos.current.range_start, pos.incoming.range_end + 1, false, conflict_lines)
      end
    end
    clear_highlights(bufnr)
    parse_buffer(bufnr)
  end
end

return M

