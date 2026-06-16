vim.pack.add({
  { src = "https://github.com/nvim-telescope/telescope.nvim", name = "telescope", version = "master" }
}, { load = true })

require('telescope').setup({})
