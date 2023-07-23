-- local navbuddy = require("nvim-navbuddy")
--
-- navbuddy.setup {
--   lsp = {
--     auto_attach = true,   -- If set to true, you don't need to manually use attach function
--     preference = nil,      -- list of lsp server names in order of preference
--   },
-- }

-- local navic = require('nvim-navic')

-- require('lspconfig').clangd.setup {
--     on_attach = function(client, bufnr)
--         navic.attach(client, bufnr)
--     end
-- }

-- navic.setup()
require("barbecue").setup({
  attach_navic = true, -- prevent barbecue from automatically attaching nvim-navic
})

-- require("lspconfig")['coc-tsserver'].setup({
--   on_attach = function(client, bufnr)
--     if client.server_capabilities["documentSymbolProvider"] then
--       require("nvim-navic").attach(client, bufnr)
--     end
--   end,
-- })
--
