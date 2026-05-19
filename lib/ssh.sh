#!/usr/bin/env sh

dev_env_validate_session_name() {
  session="${1:-}"
  if [ -z "$session" ]; then
    printf 'dev-env: empty zellij session name\n' >&2
    return 2
  fi

  case "$session" in
    *[!A-Za-z0-9._-]*)
      printf 'dev-env: invalid zellij session name: %s\n' "$session" >&2
      printf 'dev-env: use letters, numbers, dot, underscore, or dash only\n' >&2
      return 2
      ;;
  esac
}

dev_env_detect_remote_platform() {
  target="${1:-}"
  if [ -z "$target" ]; then
    printf 'dev-env: missing SSH target\n' >&2
    return 2
  fi

  ssh "$target" 'os=$(uname -s | tr "[:upper:]" "[:lower:]"); arch=$(uname -m); case "$os:$arch" in linux:x86_64|linux:amd64) echo x86_64-linux ;; linux:aarch64|linux:arm64) echo aarch64-linux ;; *) echo unsupported-$os-$arch >&2; exit 1 ;; esac'
}

dev_env_remote_has_install() {
  target="${1:-}"
  ssh "$target" 'test -x "$HOME/.local/share/dev-env/bin/dev-env"'
}

dev_env_bundle_path() {
  repo_root="${1:-}"
  platform="${2:-}"
  printf '%s\n' "$repo_root/dist/dev-env-$platform.tar.gz"
}
