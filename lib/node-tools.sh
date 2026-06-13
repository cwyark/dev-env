#!/usr/bin/env sh

dev_env_node_version_file() {
  for root in "${DEV_ENV_ROOT:-}" "${DEV_ENV_REPO:-}" "$PWD"; do
    if [ -n "$root" ] && [ -r "$root/.node-version" ]; then
      printf '%s\n' "$root/.node-version"
      return 0
    fi

    if [ -n "$root" ] && [ -r "$root/share/dev-env/source/.node-version" ]; then
      printf '%s\n' "$root/share/dev-env/source/.node-version"
      return 0
    fi
  done

  return 1
}

dev_env_fnm_command() {
  if command -v fnm >/dev/null 2>&1; then
    command -v fnm
    return 0
  fi

  if [ -n "${DEV_ENV_ROOT:-}" ] && [ -x "$DEV_ENV_ROOT/bin/fnm" ]; then
    printf '%s\n' "$DEV_ENV_ROOT/bin/fnm"
    return 0
  fi

  return 1
}

dev_env_use_fnm_node() {
  fnm_cmd="$(dev_env_fnm_command || true)"
  node_version_file="$(dev_env_node_version_file || true)"

  if [ -z "$fnm_cmd" ] || [ -z "$node_version_file" ]; then
    return 0
  fi

  node_version="$(sed -n '1p' "$node_version_file" | tr -d '[:space:]')"
  if [ -z "$node_version" ]; then
    return 0
  fi

  if ! eval "$("$fnm_cmd" env --shell bash)"; then
    return 1
  fi

  if ! "$fnm_cmd" use --install-if-missing --silent-if-unchanged "$node_version" >/dev/null; then
    return 1
  fi
}
