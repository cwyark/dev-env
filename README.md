# dev-env

Portable terminal development environment for macOS arm64 and remote Linux
x86_64/aarch64 hosts.

The design intentionally separates three concerns:

- **Nix** defines reproducible toolsets and can build per-platform bundles.
- **chezmoi** manages dotfiles/configuration without owning package installs.
- **shell entrypoints** activate or deploy the environment over SSH.

The remote-host goal is: no `apt`, no `yum`, no `brew`, no root. A remote host
should only need SSH, a POSIX shell, and a writable home or temp directory.

`bin/dev-env shell` now enters a bundled `fish` shell inside the isolated
environment. The repo no longer ships bash or zsh startup configs.
`bin/dev-env zellij-dev dev` will attach to a remote or local `dev` session,
creating it if needed.

## Essential Tools

The first-class tools are:

- `fish`
- `neovim`
- `yazi`
- `zellij`
- `btop`
- `eza`

The bundled fish runtime also enables argument completion. It ships native
completions for the `dev-env` wrapper and uses `carapace` when available for
broader command argument completions.

Interactive fish shells also alias `ls` to `eza` and provide `l`, `ll`, `la`,
and `lt` as short forms for the common list and tree views.

The Neovim audit in [docs/nvim-audit.md](docs/nvim-audit.md) also tracks tools
your current config expects, including LSPs, DAP adapters, `lazygit`, `fzf`,
`tree-sitter`, and Node-based tooling.

## Layout

```text
bin/
  dev-env          # local command dispatcher
  dev-ssh          # SSH deploy-and-enter helper
chezmoi/
  ...              # chezmoi source state
docs/
  architecture.md
  nvim-audit.md
lib/
  platform.sh      # platform detection helpers
nix/
  toolsets.nix     # package groups
scripts/
  build-bundle
  remote-install
flake.nix
```

## Local Usage

After installing Nix and chezmoi on your trusted machine:

```sh
bin/dev-env doctor
bin/dev-env shell
bin/dev-env zellij-dev dev
bin/dev-env chezmoi-apply
```

## Remote Usage

The intended remote flow is:

```sh
bin/dev-ssh user@host
bin/dev-ssh --session dev user@host
```

That command detects the remote platform, uploads a matching bundle if present,
installs it under:

```text
~/.local/share/dev-env
```

and starts:

```text
~/.local/share/dev-env/bin/dev-env shell
```

If you pass `--session dev`, it will instead start or attach to the remote
`dev` zellij session.

If the matching bundle is not present locally but the remote host already has
`~/.local/share/dev-env` installed, `dev-ssh` will skip the upload and just
connect.

## Current State

This is a scaffold. It does not yet contain prebuilt binary bundles, and Nix was
not available in the current shell when the scaffold was created, so the flake
still needs evaluation on a Nix-enabled machine.
