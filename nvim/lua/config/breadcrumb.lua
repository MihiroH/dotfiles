local breadcrumb = function()
  local breadcrumb_status_ok, breadcrumb = pcall(require, "breadcrumb")
  if not breadcrumb_status_ok then
    return
  end
  return breadcrumb.get_breadcrumb()
end

local on_attach = function (client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    breadcrumb.attach(client, bufnr)
  end
end

require("lspconfig").clangd.setup {
  on_attach = on_attach
}

-- breadcrumb.init()

local config = {
  winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { breadcrumb },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  inactive_winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { breadcrumb },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
}

require('lualine').setup(config)
