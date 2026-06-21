# AGENTS.md

## Repo Shape

- This is a shell-driven personal dev environment, not an app package or monorepo.
- Entry points are `bin/dev-env`, `bin/dev-deploy`, `bin/dev-ssh`, and `bin/dev-clean`.
- Runtime state is isolated under `${DEV_ENV_HOME:-$HOME/.local/share/dev-env}`.
- `config/` is copied into the runtime prefix; installed config under `~/.local/share/dev-env/config` is intentionally overwritten by install/deploy.

## Commands

- `bin/dev-deploy` with no target bootstraps `mise` if needed, then runs `bin/dev-env install`.
- `bin/dev-env install` copies `config/{fish,mise,nvim,opencode,yazi,zellij}`, `bin/`, and `lib/`, then runs `mise install -y`, `mise reshim`, and fish completion generation.
- `bin/dev-env update` runs `mise upgrade -y`, then the install flow.
- `bin/dev-env doctor` checks expected tools and runs `mise doctor`.
- Remote flow is `bin/dev-deploy user@host`, then `bin/dev-ssh user@host` or `bin/dev-ssh --session user@host`.
- `bin/dev-clean [ssh-target]` removes only `$DEV_ENV_HOME` after checking for `.dev-env-root`; it does not remove `~/.local/bin/mise`.

## Safe Verification

- Shell syntax baseline: `sh -n bin/dev-env bin/dev-deploy bin/dev-ssh bin/dev-clean lib/platform.sh lib/ssh.sh lib/install.sh host-dotfiles/config/dev-env/env.sh`.
- Fish syntax baseline: `fish -n config/fish/config.fish config/fish/completions/dev-env.fish runtime/etc/fish/config.fish runtime/etc/fish/completions/dev-env.fish host-dotfiles/config/fish/conf.d/dev-env.fish`.
- `shellcheck -s sh host-dotfiles/config/dev-env/env.sh` is clean; plain all-file `shellcheck` currently emits informational warnings for dynamic sources, remote SSH strings, and intentional single-quoted fish/script snippets.
- Avoid running `install`, `deploy`, or `update` casually; they write under `$DEV_ENV_HOME`, may install/upgrade tools, and can touch `~/.local/bin/dev-env`.
- For install smoke tests, use a temporary `HOME` and `DEV_ENV_HOME` so the real runtime is not clobbered.

## Implementation Notes

- Scripts are POSIX `sh` with `set -eu`; avoid Bash-only syntax in `bin/` and `lib/`.
- Template files ending in `.tmpl` are rendered during install and support only `#dev-env-if-darwin`, `#dev-env-if-linux`, and `#dev-env-endif`.
- Tool versions live in `config/mise/config.toml.tmpl`; `mise` owns global CLI tools, `fnm` owns Node, `uv` owns Python tooling, and Mason owns Neovim LSP/DAP tooling.
- Neovim uses native `vim.pack` and `config/nvim/nvim-pack-lock.json`, not lazy.nvim.
- Yazi plugins/flavors are pinned in `config/yazi/package.toml`.
