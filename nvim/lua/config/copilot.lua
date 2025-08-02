local present_, copilot_chat = pcall(require, 'CopilotChat')

if not present_ then return end

copilot_chat.setup {
  highlight_headers = false,
  separator = '---',
  error_header = '> [!ERROR] Error',
}

vim.cmd([[
  imap <silent><script><expr> <C-E> copilot#Accept("\<CR>")
  let g:copilot_no_tab_map = v:true

  imap <C-=> <Plug>(copilot-dismiss)
  imap <C-]> <Plug>(copilot-next)
]])
--
-- Quick chat with Copilot
vim.keymap.set("n", "<leader>ccq", function()
  local input = vim.fn.input("Quick Chat: ")
  if input ~= "" then
    require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
  end
end, { noremap = true, silent = true, desc = "CopilotChat - Quick chat" })

-- Show prompt actions with telescope
vim.keymap.set("n", "<leader>ccp", function()
  local actions = require("CopilotChat.actions")
  require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
end, { noremap = true, silent = true, desc = "CopilotChat - Prompt actions" })
