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
  etc/
  share/
  state/
```

Activation sets:

```sh
DEV_ENV_HOME="$HOME/.local/share/dev-env"
PATH="$DEV_ENV_HOME/bin:$PATH"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="$DEV_ENV_HOME/share"
XDG_CACHE_HOME="$DEV_ENV_HOME/cache"
```

The scaffold keeps `XDG_CONFIG_HOME` as the normal `~/.config` by default so
chezmoi can manage normal application locations. This can be switched later to a
fully private config root if you want zero dotfile writes on remotes.

### 3. chezmoi source state

chezmoi owns dotfiles and templates. It should not be the package manager.

Recommended use:

```sh
chezmoi --source ./chezmoi apply
```

The source tree is intentionally small right now. Import real configs after
deciding which files should be portable as-is and which need templates.

### 4. SSH deployment

`bin/dev-ssh` is the high-level remote entrypoint:

1. detect remote OS/arch
2. choose `dist/dev-env-$platform.tar.gz`
3. upload it to a temp directory
4. run `scripts/remote-install`
5. start the remote `dev-env shell`

## Important Tradeoff

Nix-built binaries often depend on `/nix/store`. A raw Nix closure is not the
same thing as a relocatable tarball. The scaffold starts with a simple bundle
shape, but the bundle implementation must be validated per package.

If a package is not relocatable, use one of these strategies:

- prefer official static/self-contained upstream archives for that tool
- build a truly static binary where practical
- keep Nix for local machines and use a custom artifact fetcher for remotes
- require Nix only on trusted long-lived remotes, not arbitrary hosts

## Remote Profiles

Suggested profiles:

- `core`: `neovim`, `yazi`, `zellij`, shell basics
- `nvim`: LSP/format/debug tools needed by your config
- `full`: local workstation tools

The first implementation should make `core` excellent before expanding.
