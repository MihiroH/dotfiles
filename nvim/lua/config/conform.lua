require('conform').setup({
  formatters_by_ft = {
    css = { 'prettierd' },
    scss = { 'prettierd' },
    javascript = { 'prettierd' },
    typescript = { 'prettierd' },
    typescriptreact = { 'prettierd' },
    vue = { 'prettierd' },
    svelte = { 'prettierd' },
    json = { 'prettierd' },
    html = { 'prettierd' },
    go = { 'gofmt' },
    lua = { 'stylua' },
  },
  format_on_save = function(bufnr)
    if vim.bo[bufnr].filetype == 'go' then
      return { timeout_ms = 500 }
    end
    return false
  end,
})

vim.keymap.set('n', '<leader>cf', function()
  require('conform').format({ async = true })
end, { desc = 'Format buffer' })
