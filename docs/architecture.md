# Architecture

## Goals

- Keep the remote host mostly untouched.
- Avoid distro package managers on remote hosts.
- Support `aarch64-darwin`, `x86_64-linux`, and `aarch64-linux`.
- Make `neovim`, `yazi`, and `zellij` available everywhere.
- Keep machine-specific config manageable without branches or symlink farms.

## Layers

### 1. Nix package definitions

Nix owns reproducible package selection and bundle assembly. It is expected to
run on trusted local/build machines, not necessarily on every remote host.

The flake exposes:

- `devShells.default`
- `packages.default`
- `packages.bundle`

### 2. Portable runtime prefix

Remote systems use a private prefix:

```text
~/.local/share/dev-env
  bin/
  cache/
  config/
  etc/
  share/
  state/
```

Activation sets:

```sh
DEV_ENV_HOME="$HOME/.local/share/dev-env"
PATH="$DEV_ENV_HOME/bin:$PATH"
XDG_CONFIG_HOME="$DEV_ENV_HOME/config"
XDG_DATA_HOME="$DEV_ENV_HOME/share"
XDG_CACHE_HOME="$DEV_ENV_HOME/cache"
XDG_STATE_HOME="$DEV_ENV_HOME/state"
```

Temporary files continue to use the host's system temporary directory
(`TMPDIR`, usually `/tmp`). The runtime does not override `TMPDIR`.

Disposable remote use should keep config, cache, and state under the private
prefix so removing `~/.local/share/dev-env` removes the development
environment. The bundle includes a `.dev-env-root` marker so cleanup tools can
refuse unsafe deletes.

The `dev-env shell` entrypoint is fish-first and should launch the bundled fish
runtime with its own config from `etc/fish/config.fish`. The repo no longer
ships bash or zsh startup files.

### 3. chezmoi source state

chezmoi owns dotfiles and templates. It should not be the package manager.
It is intended for trusted hosts because applying it writes normal home
dotfiles outside `DEV_ENV_HOME`.

Recommended use:

```sh
chezmoi --source ./chezmoi apply
```

The source tree is intentionally small right now. Import real configs after
deciding which files should be portable as-is and which need templates.

### 4. SSH deployment

`bin/dev-deploy` is the deployment entrypoint:

1. detect remote OS/arch
2. choose `dist/dev-env-$platform.tar.gz` for local installs
3. upload a source snapshot to a temp directory on remote hosts
4. run `nix build` on the remote host
5. install the resulting bundle

When called without an SSH target, `bin/dev-deploy` detects the local platform
and installs the matching local bundle.

Remote deployment expects Nix to be installed on the target host.

`bin/dev-ssh` is the remote entrypoint for machines that already have
`~/.local/share/dev-env` installed. It does not upload or install bundles.

For the common "jump straight into the `dev` zellij session" workflow, deploy
first and then connect:

```sh
bin/dev-deploy user@host
bin/dev-ssh --session user@host
```

This calls `dev-env zellij dev` on the remote host, which attaches to `dev`
or creates it when it is not running yet.

Zellij sessions are long-lived. If you rely on SSH agent forwarding, remember
that `SSH_AUTH_SOCK` belongs to the SSH connection that created the session.
Reattaching to an older session can leave the socket path stale. In that case,
start a fresh zellij session for the new SSH login or use a host-local agent
with a stable socket.

The dev-env wrapper forces `TERM=xterm-256color` only for Zellij launches so
the multiplexer uses a conservative terminal description even when Ghostty
reports `xterm-ghostty` to the outer shell.

`bin/dev-clean` removes an installed local or remote prefix:

```sh
bin/dev-clean user@host
```

It removes only `~/.local/share/dev-env` and only when `.dev-env-root` exists.

## Important Tradeoff

Nix-built binaries often depend on `/nix/store`. A raw Nix closure is not the
same thing as a relocatable tarball. The scaffold starts with a simple bundle
shape, but the bundle implementation must be validated per package.

The current bundle step dereferences the runtime `bin/` tree before archiving
so the shipped tarball contains real executable files instead of symlinks to
the Nix store.

If a package is not relocatable, use one of these strategies:

- prefer official static/self-contained upstream archives for that tool
- build a truly static binary where practical
- keep Nix for local machines and use a custom artifact fetcher for remotes

## Remote Profiles

Suggested profiles:

- `core`: `neovim`, `yazi`, `zellij`, `sshfs`, shell basics
- `nvim`: LSP/format/debug tools needed by your config
- `full`: local workstation tools

The first implementation should make `core` excellent before expanding.
