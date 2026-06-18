# Neovim Tool Audit

This config is now designed for the mise-based `dev-env` runtime.

## Essential Binaries

- `nvim`
- `yazi`
- `zellij`
- `cmake`

These are installed by mise from the isolated config at:

```text
~/.local/share/dev-env/config/mise/config.toml
```

## Referenced By Plugins Or Config

- `lazygit`: `toggleterm` opens `lazygit`
- `fzf`: `fzf.vim` checks for the `fzf` executable
- `fnm`: installed by mise and used for project-managed Node runtimes
- `uv`: installed by mise and used for Python/project tooling
- `opencode`: install through mise if needed globally
- `tree-sitter`: install through mise if parser compilation needs the CLI
- `cargo`: required by the SnipRun config on macOS when running Rust snippets
- `cmake`: used for CMake-based projects alongside `neocmake`

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

## Portability Notes

- Mason downloads and installs editor tooling on the target host.
- Mason state is isolated because `XDG_DATA_HOME` points at
  `~/.local/share/dev-env/share`.
- `tree-sitter` parser compilation can require a compiler. Treat parser build
  failures as editor capability issues, not deploy failures.
- Node-based project tools should use `fnm` inside dev-env shells, not the remote
  system Node.
- DAP support is the least portable layer and should remain optional until the
  core editor experience is stable.
