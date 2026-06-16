#!/usr/bin/env sh

set -eu

dev_env_uname_s() {
  uname -s | tr '[:upper:]' '[:lower:]'
}

dev_env_uname_m() {
  uname -m
}

dev_env_is_wsl() {
  [ -r /proc/version ] && grep -qi microsoft /proc/version 2>/dev/null
}

dev_env_platform() {
  os="$(dev_env_uname_s)"
  arch="$(dev_env_uname_m)"

  case "$os:$arch" in
    darwin:arm64|darwin:aarch64) printf '%s\n' "macos-arm64" ;;
    darwin:x86_64|darwin:amd64) printf '%s\n' "macos-x86_64" ;;
    linux:x86_64|linux:amd64)
      if dev_env_is_wsl; then
        printf '%s\n' "wsl-linux-x86_64"
      else
        printf '%s\n' "linux-x86_64"
      fi
      ;;
    linux:aarch64|linux:arm64)
      if dev_env_is_wsl; then
        printf '%s\n' "wsl-linux-arm64"
      else
        printf '%s\n' "linux-arm64"
      fi
      ;;
    *)
      printf '%s\n' "unsupported-$os-$arch" >&2
      return 1
      ;;
  esac
}

dev_env_default_home() {
  printf '%s\n' "${DEV_ENV_HOME:-$HOME/.local/share/dev-env}"
}
