#!/usr/bin/env sh

dev_env_bun_install_dir() {
  printf '%s\n' "${BUN_INSTALL:-${DEV_ENV_HOME:-$HOME/.local/share/dev-env}/bun}"
}

dev_env_activate_bun() {
  bun_install_dir="$(dev_env_bun_install_dir)"
  export BUN_INSTALL="$bun_install_dir"

  case ":$PATH:" in
    *":$bun_install_dir/bin:"*) ;;
    *) PATH="$bun_install_dir/bin:$PATH"; export PATH ;;
  esac

  mkdir -p "$bun_install_dir/bin"
}

dev_env_ensure_bun_tools() {
  if command -v opencode >/dev/null 2>&1 && command -v tree-sitter >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v bun >/dev/null 2>&1; then
    printf 'dev-env: bun is unavailable, cannot install opencode or tree-sitter-cli\n' >&2
    return 0
  fi

  dev_env_activate_bun

  if command -v opencode >/dev/null 2>&1 && command -v tree-sitter >/dev/null 2>&1; then
    return 0
  fi

  if ! bun add -g opencode-ai@1.17.4 tree-sitter-cli >/dev/null; then
    printf 'dev-env: failed to install opencode or tree-sitter-cli with bun\n' >&2
    return 0
  fi

  if ! command -v opencode >/dev/null 2>&1; then
    printf 'dev-env: opencode still unavailable after bun install\n' >&2
  fi

  if ! command -v tree-sitter >/dev/null 2>&1; then
    printf 'dev-env: tree-sitter still unavailable after bun install\n' >&2
  fi
}
