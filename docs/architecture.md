# Architecture

## Goals

- Keep the user environment isolated under `~/.local/share/dev-env`.
- Avoid root and distro package managers on remote Linux hosts where possible.
- Support macOS, Linux x86_64/aarch64, and WSL through the same scripts.
- Use mise for exact pinned global tools instead of Nix closures or tarballs.
- Keep Neovim, Yazi, Zellij, and fish config portable and disposable.

## Layers

### 1. Tool Management

`mise` owns global CLI tools declared in `config/mise/config.toml`. The installed
config lives at:

```text
~/.local/share/dev-env/config/mise/config.toml
```

`dev-env` sets:

```sh
MISE_GLOBAL_CONFIG_FILE="$DEV_ENV_HOME/config/mise/config.toml"
```

so it does not depend on or modify the user's normal `~/.config/mise`.

Installed tools are isolated under:

```text
~/.local/share/dev-env/share/mise
```

Only the `mise` bootstrap binary itself is expected to live outside the prefix,
usually at `~/.local/bin/mise`.

### 2. Isolated Runtime Prefix

The runtime prefix is:

```text
~/.local/share/dev-env
  bin/
  cache/
  config/
  share/
  source/
  state/
```

Activation sets:

```sh
DEV_ENV_HOME="$HOME/.local/share/dev-env"
PATH="$HOME/.local/bin:$DEV_ENV_HOME/bin:$PATH"
XDG_CONFIG_HOME="$DEV_ENV_HOME/config"
XDG_DATA_HOME="$DEV_ENV_HOME/share"
XDG_CACHE_HOME="$DEV_ENV_HOME/cache"
XDG_STATE_HOME="$DEV_ENV_HOME/state"
MISE_GLOBAL_CONFIG_FILE="$DEV_ENV_HOME/config/mise/config.toml"
MISE_DATA_DIR="$DEV_ENV_HOME/share/mise"
MISE_CACHE_DIR="$DEV_ENV_HOME/cache/mise"
MISE_STATE_DIR="$DEV_ENV_HOME/state/mise"
```

### 3. Runtime Config

Portable config lives under `config/` and is copied into the isolated prefix by
`dev-env install`. Existing files under `~/.local/share/dev-env/config` are
overwritten intentionally.

Template files ending in `.tmpl` are rendered during install. The renderer keeps
the existing small `#dev-env-if-darwin` / `#dev-env-endif` conditional support.

### 4. SSH Deployment

`bin/dev-deploy` is the deployment entrypoint:

1. detect remote OS/arch
2. install mise to `~/.local/bin` if missing
3. upload this repo to `~/.local/share/dev-env/source`
4. run `~/.local/share/dev-env/source/bin/dev-env install`
5. run `~/.local/share/dev-env/bin/dev-env doctor`

Remote deployment requires SSH, `sh`, `tar`, and either `curl` or `wget`. It does
not require Nix, Docker, root, or system package managers.

### 5. Entering Remotes

`bin/dev-ssh` only enters an already-installed remote. It runs:

```text
~/.local/share/dev-env/bin/dev-env shell
```

With `--session`, it starts or attaches a Zellij session through:

```text
~/.local/share/dev-env/bin/dev-env zellij dev
```

### 6. Cleanup

`bin/dev-clean` removes only `~/.local/share/dev-env` after checking for the
`.dev-env-root` marker. Because `MISE_DATA_DIR`, `MISE_CACHE_DIR`, and
`MISE_STATE_DIR` live under `DEV_ENV_HOME`, cleanup removes mise-installed tools
for this environment. It intentionally does not remove:

```text
~/.local/bin/mise
```

## Tool Ownership

- `mise`: fish, Neovim, Zellij, Yazi, CLI tools, `fnm`, and `uv`
- `fnm`: Node runtimes
- `uv`: Python/project tooling
- Mason: Neovim LSPs, formatters, and DAP adapters

This is a pragmatic consistency model, not a Nix-style reproducible closure.
