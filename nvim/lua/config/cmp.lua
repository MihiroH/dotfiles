require('blink.cmp').setup({
  keymap = {
    preset = 'none',
    ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-x>'] = { 'hide', 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },
    ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
  },

  completion = {
    -- Don't preselect first item (explicit selection required, like CoC)
    list = { selection = { preselect = false, auto_insert = false } },

    -- Auto-brackets on completion accept
    accept = { auto_brackets = { enabled = true } },

    -- Show documentation when selecting a completion item
    documentation = { auto_show = true, auto_show_delay_ms = 500 },
  },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },

  cmdline = {
    keymap = {
      ['<Tab>'] = { 'show_and_insert_or_accept_single', 'select_next' },
      ['<S-Tab>'] = { 'select_prev', 'fallback' },
      ['<CR>'] = { 'accept_and_enter', 'fallback' },
      ['<C-x>'] = { 'cancel', 'fallback' },
    },
  },

  signature = { enabled = true },
})
