# Neovim Tool Audit

Derived from reading `~/.config/nvim` on 2026-05-16.

## Essential Binaries

- `nvim`
- `yazi`
- `zellij`

## Referenced By Plugins Or Config

- `lazygit`: `toggleterm` opens `lazygit`
- `fzf`: `fzf.vim` checks for the `fzf` executable
- `fnm`: bundled for project-managed Node runtimes
- `opencode`: provided by the dev-env Nix toolset
- `tree-sitter`: provided by the dev-env Nix toolset
- `cargo`: required by the SnipRun config on macOS

## LSP Servers

Configured or ensured through Mason:

- `lua_ls`
- `rust_analyzer`
- `clangd`
- `pyright`
- `ruff`
- `zls`
- `neocmake`
- `biome`
- `taplo`
- `bashls`

## DAP Adapters

Configured through `mason-nvim-dap`:

- `python`
- `codelldb`
- `bash`

## Treesitter Parsers

Requested parsers:

- `c`
- `cpp`
- `css`
- `bash`
- `lua`
- `cmake`
- `dockerfile`
- `python`
- `rust`
- `markdown`
- `javascript`
- `typescript`
- `zig`
- `xml`
- `yaml`
- `toml`
- `regex`

## Likely Languages

The current config and repo shape point to these languages as your regular set:

- Lua for Neovim config
- Python
- Rust
- C and C++
- CMake
- JavaScript and TypeScript
- Shell scripts
- TOML

## Portability Notes

- Mason is convenient, but it downloads and installs tools on the target host.
  For maximum portability, prefer binaries provided by the dev-env tool bundle.
- `tree-sitter` parser compilation can require a compiler. Remote profiles
  should either ship parsers or accept a reduced parser set.
- Node-based project tools should use the bundled `fnm` in dev-env shells, not
  the remote system Node.
- DAP support is the least portable layer and should be treated as optional
  until the core editor experience is stable.
