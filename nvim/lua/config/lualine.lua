local symbols = {
  { 'bc1_s', '  ', 'bc1_m', 'bc1_e', ' >' },
  { 'bc2_s', ' 󰊕 ', 'bc2_m', 'bc2_e', ' %##%#bc2_e#' },
  { 'bc3_s', '  ', 'bc3_m', 'bc3_e', '%##%#bc3_e#' },
}

-- show breadcrumbs if available
local function breadcrumbs()
  local items = vim.b.coc_nav
  local t = {''}
  if items then
    for k,v in ipairs(items) do
      setmetatable(v, { __index = function(table, key)
        return ''
      end})
      t[#t+1] = '%#' .. (symbols[k][1] or 'Normal') .. '#' ..
                (symbols[k][2] or '') ..
                '%#' .. (symbols[k][3] or 'Normal') .. '#' ..
                (v.name or '')
      if next(items,k) ~= nil then
        t[#t+1] = '%#' .. (symbols[k][4] or 'Normal') .. '#' ..
                  (symbols[k][5] or '')
      end
    end
  end
  return table.concat(t)
end

require('lualine').setup {
  options = {
    icons_enabled = true,
  },
  sections = {
    lualine_c = {
      -- {'filename',
      --   path = 1, -- 1: Relative path
      -- },
      {breadcrumbs},
    }
  },
  extensions = { 'fern', 'quickfix', }
}
