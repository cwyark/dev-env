# Neovim Tool Audit

Derived from reading `~/.config/nvim` on 2026-05-16.

## Essential Binaries

- `nvim`
- `yazi`
- `zellij`

## Referenced By Plugins Or Config

- `lazygit`: `toggleterm` opens `lazygit`
- `fzf`: `fzf.vim` checks for the `fzf` executable
- `node`/`npm`: local Node installer and `TSInstallCLI`
- `tree-sitter`: installed through `npm install -g tree-sitter-cli`
- `cargo`: required by the SnipRun config on macOS

## LSP Servers

Configured or ensured through Mason:

- `lua_ls`
- `rust_analyzer`
- `clangd`
- `pyright`
- `ruff`
- `neocmake`
- `biome`
- `taplo`

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

## Portability Notes

- Mason is convenient, but it downloads and installs tools on the target host.
  For maximum portability, prefer binaries provided by the dev-env tool bundle.
- `tree-sitter` parser compilation can require a compiler. Remote profiles
  should either ship parsers or accept a reduced parser set.
- Node-based tools should use a bundled Node runtime or a pinned local runtime,
  not the remote system Node.
- DAP support is the least portable layer and should be treated as optional
  until the core editor experience is stable.
