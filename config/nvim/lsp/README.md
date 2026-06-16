# Project-local LSP overrides

This folder is for **project-specific** LSP configuration. Neovim (0.11+) will
auto-discover `lsp/*.lua` files from the project root and merge them with your
global config.

## Usage
Create a file named after the server, for example:

- `lsp/clangd.lua`
- `lsp/pyright.lua`
- `lsp/tsserver.lua`

Each file should return a Lua table with server options:

```lua
return {
  settings = {
    -- server-specific settings
  },
}
```

## Examples

`lsp/clangd.lua`

```lua
return {
  cmd = { "clangd", "--background-index", "--clang-tidy" },
}
```

`lsp/pyright.lua`

```lua
return {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "strict",
      },
    },
  },
}
```

## Notes
- These files only apply to the **current project**.
- They override and extend global defaults defined in `lua/config/lsp.lua`.
