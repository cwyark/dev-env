#!/usr/bin/env sh

dev_env_install_home() {
  printf '%s\n' "${DEV_ENV_HOME:-$HOME/.local/share/dev-env}"
}

dev_env_make_tree_removable() {
  tree="${1:-}"
  if [ -n "$tree" ] && [ -d "$tree" ]; then
    chmod -R u+rwX "$tree" 2>/dev/null || true
  fi
}

dev_env_install_copy_config_dir() {
  source_dir="${1:-}"
  target_dir="${2:-}"
  if [ -z "$source_dir" ] || [ -z "$target_dir" ] || [ ! -d "$source_dir" ]; then
    return 0
  fi

  rm -rf "$target_dir"
  mkdir -p "$target_dir"
  (
    cd "$source_dir"
    find . -type d -exec mkdir -p "$target_dir/{}" \;
    find . -type f | while IFS= read -r source_file; do
      target_file="$target_dir/$source_file"
      case "$target_file" in
        *.tmpl) target_file="${target_file%.tmpl}" ;;
      esac
      mkdir -p "$(dirname "$target_file")"
      if [ "${source_file##*.}" = "tmpl" ]; then
        dev_env_install_render_template "$source_file" > "$target_file"
      else
        cp -a "$source_file" "$target_file"
      fi
    done
  )
}

dev_env_install_render_template() {
  template="${1:-}"
  if [ -z "$template" ]; then
    return 2
  fi

  case "$(uname -s 2>/dev/null || true)" in
    Darwin) dev_env_os="darwin" ;;
    Linux) dev_env_os="linux" ;;
    *) dev_env_os="unknown" ;;
  esac

  awk -v dev_env_os="$dev_env_os" '
    $0 ~ /^[[:space:]]*#dev-env-if-darwin[[:space:]]*$/ {
      darwin_only = 1
      next
    }
    $0 ~ /^[[:space:]]*#dev-env-endif[[:space:]]*$/ {
      darwin_only = 0
      next
    }
    darwin_only && dev_env_os != "darwin" {
      next
    }
    {
      print
    }
  ' "$template"
}

dev_env_install_runtime_config() {
  install_root="${1:-}"
  if [ -z "$install_root" ]; then
    return 2
  fi

  DEV_ENV_ROOT="$install_root"
  export DEV_ENV_ROOT

  dev_env_install_copy_config_dir "$install_root/config-source/nvim" "$install_root/config/nvim"
  dev_env_install_copy_config_dir "$install_root/config-source/yazi" "$install_root/config/yazi"
  dev_env_install_copy_config_dir "$install_root/config-source/zellij" "$install_root/config/zellij"
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
  dev_env_make_tree_removable "$staging"

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
  dev_env_install_runtime_config "$DEV_ENV_HOME"
  if [ -d "$previous" ]; then
    dev_env_make_tree_removable "$previous"
    if ! rm -rf "$previous"; then
      printf 'warning: installed dev-env, but failed to remove backup: %s\n' "$previous" >&2
    fi
  fi

  chmod +x "$DEV_ENV_HOME/bin/"* 2>/dev/null || true
  printf 'installed dev-env to %s\n' "$DEV_ENV_HOME"
}
