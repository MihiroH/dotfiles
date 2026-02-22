require('conform').setup({
  formatters_by_ft = {
    css = { 'prettier' },
    scss = { 'prettier' },
    javascript = { 'prettier' },
    typescript = { 'prettier' },
    typescriptreact = { 'prettier' },
    vue = { 'prettier' },
    svelte = { 'prettier' },
    json = { 'prettier' },
    html = { 'prettier' },
    go = { 'gofmt' },
    lua = { 'stylua' },
  },
  format_on_save = false,
})

vim.keymap.set('n', '<leader>cf', function()
  require('conform').format({ async = true })
end, { desc = 'Format buffer' })
