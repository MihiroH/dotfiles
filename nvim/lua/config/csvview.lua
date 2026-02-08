local present, csvview = pcall(require, 'csvview')

if not present then return end

csvview.setup()

-- Auto-enable CSVView for CSV and TSV files
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { '*.csv', '*.tsv' },
  callback = function()
    vim.cmd('CsvViewEnable')
  end,
})
