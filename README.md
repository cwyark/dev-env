# dev-env

Portable terminal development environment for macOS arm64 and remote Linux
x86_64/aarch64 hosts.

The design intentionally separates three concerns:

- **Nix** defines reproducible toolsets and can build per-platform bundles.
- **chezmoi** manages dotfiles/configuration without owning package installs.
- **shell entrypoints** activate or deploy the environment over SSH.

The remote-host goal is: no `apt`, no `yum`, no `brew`, no root. A remote host
should only need SSH, Nix, a POSIX shell, and a writable home or temp
directory.

`bin/dev-env shell` now enters a bundled `fish` shell inside the isolated
environment. The repo no longer ships bash or zsh startup configs.
`bin/dev-env zellij dev` will attach to a remote or local `dev` session,
creating it if needed.

## Essential Tools

The first-class tools are:

- `fish`
- `neovim`
- `yazi`
- `zellij`
- `btop`
- `eza`
- `sshfs`
- `cmake`

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
  dev-ssh          # SSH enter helper for installed remotes
  dev-deploy       # local/SSH bundle deployment helper
  dev-clean        # local/SSH cleanup helper
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
flake.nix
```

## Local Usage

After installing Nix and chezmoi on your trusted machine:

```sh
bin/dev-env doctor
bin/dev-env shell
bin/dev-env zellij dev
bin/dev-env chezmoi-apply # trusted host dotfiles only
```

## Remote Usage

The intended remote flow is:

```sh
bin/dev-deploy user@host
bin/dev-ssh user@host
bin/dev-ssh --session user@host
bin/dev-clean user@host
```

`dev-deploy` detects the target platform, uploads the source tree, builds the
matching bundle on the remote with Nix, and installs it under:

```text
~/.local/share/dev-env
```

The activated remote environment keeps runtime config, cache, and state under
that same prefix:

```text
~/.local/share/dev-env/config
~/.local/share/dev-env/cache
~/.local/share/dev-env/state
```

Temporary files continue to use the host's system temporary directory
(`TMPDIR`, usually `/tmp`).

`dev-ssh` does not build, upload, or install bundles. It only connects to an
already-installed remote and starts:

```text
~/.local/share/dev-env/bin/dev-env shell
```

If you pass `--session`, it will instead start or attach to the remote `dev`
zellij session. You can also pass a custom session name:

```sh
bin/dev-ssh --session work user@host
```

To install the matching bundle on the local machine, omit the SSH target:

```sh
bin/dev-deploy
```

If the matching bundle is not present locally, `dev-deploy` exits with the
bundle path and the `scripts/build-bundle <platform>` command to run.

`dev-clean` removes only `~/.local/share/dev-env`, and refuses to run unless the
directory contains the bundle marker file `.dev-env-root`.

`bin/dev-env chezmoi-apply` is for trusted hosts. It applies normal home
dotfiles and is not part of the disposable remote flow.

## Bundle Build

Use `scripts/build-bundle` as the single bundle build entry point:

```sh
scripts/build-bundle mac-m1
scripts/build-bundle linux-x86_64
scripts/build-bundle linux-arm64
```

`mac-m1` builds the `aarch64-darwin` bundle locally with Nix. The Linux targets
build inside a container with Colima and write the matching artifact to `dist/`.

Before building Linux bundles on macOS, start a Colima instance with containerd.
For `linux-x86_64` on Apple Silicon, enable Rosetta:

```sh
colima start --disk 16 --vm-type=vz --vz-rosetta --runtime containerd
```

The Linux build path is a thin shell around:

```sh
colima nerdctl -- build \
  --platform linux/amd64 \
  --build-arg BUNDLE_SYSTEM=x86_64-linux \
  --target bundle \
  --output type=local,dest=dist \
  -f docker/Dockerfile.bundle-builder \
  .
```

The resulting artifacts are written to:

```text
dist/dev-env-aarch64-darwin.tar.gz
dist/dev-env-x86_64-linux.tar.gz
dist/dev-env-aarch64-linux.tar.gz
```

The builder image is based on Alpine and installs Nix with `apk`. On macOS the
build uses Colima's `nerdctl` wrapper rather than the Docker socket path.

## Current State

This is a scaffold. It does not yet contain prebuilt binary bundles, and Nix was
not available in the current shell when the scaffold was created, so the flake
still needs evaluation on a Nix-enabled machine.
