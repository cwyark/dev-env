vim.pack.add({
  {
    src = "https://github.com/saghen/blink.cmp",
    version = vim.version.range("1")
  }
})

require("blink.cmp").setup({
  keymap = vim.g.blink_cmp_keymap or { preset = 'default' },
  appearance = {
    nerd_font_variant = 'mono',
  },
  completion = {
    documentation = { auto_show = true },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  signature = {
    enabled = true
  },
  fuzzy = { implementation = 'lua' },
})
