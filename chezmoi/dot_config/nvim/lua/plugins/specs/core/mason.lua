vim.pack.add {
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" }
}

local ensure_installed = {
  "lua_ls",
  "clangd",
  "pyright",
  "ruff",
  "rust_analyzer",
  "zls",
  "neocmake",
  "biome",
  "taplo",
  "bashls",
}

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = ensure_installed,
  automatic_installation = true,
})
