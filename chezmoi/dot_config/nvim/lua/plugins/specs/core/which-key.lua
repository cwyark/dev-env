vim.pack.add({
  {
    src = "https://github.com/folke/which-key.nvim",
    name = "which-key",
    version = "main"
  }
}, { load = true })

require('which-key').setup({
  preset = "helix",
})
