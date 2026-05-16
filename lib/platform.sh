#!/usr/bin/env sh

set -eu

dev_env_uname_s() {
  uname -s | tr '[:upper:]' '[:lower:]'
}

dev_env_uname_m() {
  uname -m
}

dev_env_platform() {
  os="$(dev_env_uname_s)"
  arch="$(dev_env_uname_m)"

  case "$os:$arch" in
    darwin:arm64) printf '%s\n' "aarch64-darwin" ;;
    linux:x86_64|linux:amd64) printf '%s\n' "x86_64-linux" ;;
    linux:aarch64|linux:arm64) printf '%s\n' "aarch64-linux" ;;
    *)
      printf '%s\n' "unsupported-$os-$arch" >&2
      return 1
      ;;
  esac
}

dev_env_default_home() {
  printf '%s\n' "${DEV_ENV_HOME:-$HOME/.local/share/dev-env}"
}
