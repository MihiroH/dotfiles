local present, img_clip = pcall(require, 'img-clip')

if not present then return end

img_clip.setup({
  default = {
    embed_image_as_base64 = false,
    prompt_for_file_name = false,
    drag_and_drop = {
      insert_mode = true,
    },
  },
})

-- Key mappings
local map = require('config.utils').map
local opts = { noremap = true, silent = true }

map('n', '<leader>p', '<cmd>PasteImage<cr>', opts)
