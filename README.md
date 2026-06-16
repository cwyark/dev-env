# dev-env

Personal terminal development environment for macOS, Linux, and WSL hosts.

`dev-env` is no longer a Nix bundle or portable tarball builder. It keeps a
small isolated runtime under `~/.local/share/dev-env` and uses
[mise](https://mise.jdx.dev/) to install exact pinned global tools.

## Design

- `mise` installs global CLI tools from `config/mise/config.toml`.
- `dev-env` keeps fish, Neovim, Yazi, Zellij, and mise config isolated under
  `~/.local/share/dev-env/config`.
- `fnm` is installed by mise and manages Node.
- `uv` is installed by mise and manages Python/project tooling.
- Neovim Mason remains responsible for LSPs, formatters, and DAP adapters.
- Remote deployment bootstraps mise over SSH and runs `dev-env install`.

## Layout

```text
bin/
  dev-env          # local command dispatcher
  dev-ssh          # SSH enter helper for installed remotes
  dev-deploy       # local/SSH deployment helper
  dev-clean        # local/SSH cleanup helper
config/
  fish/            # isolated fish startup and completions
  mise/            # exact pinned global tools
  nvim/            # isolated Neovim config
  yazi/            # isolated Yazi config
  zellij/          # isolated Zellij config
docs/
  architecture.md
  nvim-audit.md
host-dotfiles/
  ...              # optional host shell snippets
lib/
  platform.sh
  ssh.sh
  install.sh
```

## Local Usage

Install or update the local isolated environment:

```sh
bin/dev-deploy
bin/dev-env shell
bin/dev-env zellij dev
```

`bin/dev-deploy` without an SSH target runs `bin/dev-env install`, which copies
config to `~/.local/share/dev-env/config` and runs `mise install`.

## Remote Usage

```sh
bin/dev-deploy user@host
bin/dev-ssh user@host
bin/dev-ssh --session user@host
bin/dev-clean user@host
```

Remote deployment expects SSH, a POSIX shell, `tar`, and either `curl` or `wget`.
It does not require Nix, Docker, root, `apt`, `yum`, or Homebrew.

`dev-deploy` overwrites existing files under:

```text
~/.local/share/dev-env/config
```

The `mise` bootstrap binary may live at `~/.local/bin/mise`, but tools installed
by mise are isolated under `~/.local/share/dev-env/share/mise`.

## Runtime Prefix

```text
~/.local/share/dev-env
  bin/
  config/
  cache/
  share/
  source/
  state/
```

Activated commands use:

```sh
DEV_ENV_HOME="$HOME/.local/share/dev-env"
XDG_CONFIG_HOME="$DEV_ENV_HOME/config"
XDG_DATA_HOME="$DEV_ENV_HOME/share"
XDG_CACHE_HOME="$DEV_ENV_HOME/cache"
XDG_STATE_HOME="$DEV_ENV_HOME/state"
MISE_GLOBAL_CONFIG_FILE="$DEV_ENV_HOME/config/mise/config.toml"
MISE_DATA_DIR="$DEV_ENV_HOME/share/mise"
MISE_CACHE_DIR="$DEV_ENV_HOME/cache/mise"
MISE_STATE_DIR="$DEV_ENV_HOME/state/mise"
```

## Updating

```sh
bin/dev-env update
```

This runs `mise upgrade`, then `mise install`, then reshims tools when supported.
