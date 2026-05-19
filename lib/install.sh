#!/usr/bin/env sh

dev_env_install_home() {
  printf '%s\n' "${DEV_ENV_HOME:-$HOME/.local/share/dev-env}"
}

dev_env_install_archive() {
  archive="${1:-}"
  if [ -z "$archive" ]; then
    printf 'usage: remote-install <archive.tar.gz>\n' >&2
    return 2
  fi

  DEV_ENV_HOME="$(dev_env_install_home)"
  staging="${TMPDIR:-/tmp}/dev-env.staging.$$"
  previous="$DEV_ENV_HOME.previous.$(date +%Y%m%d%H%M%S)"
  parent="$(dirname "$DEV_ENV_HOME")"

  rm -rf "$staging"
  mkdir -p "$staging"
  if ! tar -xzf "$archive" -C "$staging"; then
    rm -rf "$staging"
    return 1
  fi

  if ! mkdir -p "$parent"; then
    rm -rf "$staging"
    printf 'error: cannot create install parent: %s\n' "$parent" >&2
    return 1
  fi
  if [ -e "$DEV_ENV_HOME" ] && [ ! -w "$DEV_ENV_HOME" ]; then
    rm -rf "$staging"
    printf 'error: install target is not writable: %s\n' "$DEV_ENV_HOME" >&2
    printf 'hint: fix ownership or remove the existing directory, then retry\n' >&2
    return 1
  fi
  if [ -d "$DEV_ENV_HOME" ]; then
    mv "$DEV_ENV_HOME" "$previous"
  fi
  mv "$staging" "$DEV_ENV_HOME"
  if [ -d "$previous" ]; then
    if ! rm -rf "$previous"; then
      printf 'warning: installed dev-env, but failed to remove backup: %s\n' "$previous" >&2
    fi
  fi

  chmod +x "$DEV_ENV_HOME/bin/"* 2>/dev/null || true
  printf 'installed dev-env to %s\n' "$DEV_ENV_HOME"
}
