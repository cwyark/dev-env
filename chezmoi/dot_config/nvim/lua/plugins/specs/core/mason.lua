vim.pack.add {
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" }
}

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    "lua_ls",        -- lua
    "rust_analyzer", -- rust
    "clangd",        -- c/c++
    "pyright",       -- python
    "ruff",          -- python
    "neocmake",      -- cmake
    "biome",         -- json, javascript
    "taplo"          -- toml
  },
})
