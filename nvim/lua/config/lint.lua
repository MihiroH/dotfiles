local lint = require('lint')

lint.linters_by_ft = {
  css = { 'stylelint' },
  scss = { 'stylelint' },
  python = { 'flake8' },
  go = { 'staticcheck' },
}

vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  callback = function()
    lint.try_lint()
  end,
})
