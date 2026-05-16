vim.pack.add({
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim", name = "render-markdown", version = "main" },
})
require('render-markdown').setup({
  file_types = { "markdown", "codecompanion" },
}) -- only mandatory if you want to set custom options
