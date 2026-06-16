#!/usr/bin/env sh

dev_env_install_home() {
  printf '%s\n' "${DEV_ENV_HOME:-$HOME/.local/share/dev-env}"
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
    $0 ~ /^[[:space:]]*#dev-env-if-linux[[:space:]]*$/ {
      linux_only = 1
      next
    }
    $0 ~ /^[[:space:]]*#dev-env-endif[[:space:]]*$/ {
      darwin_only = 0
      linux_only = 0
      next
    }
    darwin_only && dev_env_os != "darwin" {
      next
    }
    linux_only && dev_env_os != "linux" {
      next
    }
    {
      print
    }
  ' "$template"
}

dev_env_install_copy_config_dir() {
  source_dir="${1:-}"
  target_dir="${2:-}"
  if [ -z "$source_dir" ] || [ -z "$target_dir" ] || [ ! -d "$source_dir" ]; then
    return 0
  fi

  mkdir -p "$target_dir"
  (
    cd "$source_dir" || exit 1
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

dev_env_install_runtime_config() {
  install_root="${1:-}"
  source_root="${2:-}"
  if [ -z "$install_root" ] || [ -z "$source_root" ]; then
    return 2
  fi

  rm -rf "$install_root/config"
  mkdir -p "$install_root/config"
  dev_env_install_copy_config_dir "$source_root/config/fish" "$install_root/config/fish"
  dev_env_install_copy_config_dir "$source_root/config/mise" "$install_root/config/mise"
  dev_env_install_copy_config_dir "$source_root/config/nvim" "$install_root/config/nvim"
  dev_env_install_copy_config_dir "$source_root/config/yazi" "$install_root/config/yazi"
  dev_env_install_copy_config_dir "$source_root/config/zellij" "$install_root/config/zellij"
}

dev_env_install_source() {
  source_root="${1:-}"
  if [ -z "$source_root" ]; then
    printf 'usage: dev_env_install_source /path/to/dev-env-source\n' >&2
    return 2
  fi
  if [ ! -d "$source_root" ]; then
    printf 'error: source root is not available: %s\n' "$source_root" >&2
    return 1
  fi

  DEV_ENV_HOME="$(dev_env_install_home)"
  parent="$(dirname "$DEV_ENV_HOME")"
  if ! mkdir -p "$parent" "$DEV_ENV_HOME"; then
    printf 'error: cannot create install target: %s\n' "$DEV_ENV_HOME" >&2
    return 1
  fi
  if [ ! -w "$DEV_ENV_HOME" ]; then
    printf 'error: install target is not writable: %s\n' "$DEV_ENV_HOME" >&2
    return 1
  fi

  : > "$DEV_ENV_HOME/.dev-env-root"
  mkdir -p \
    "$DEV_ENV_HOME/bin" \
    "$DEV_ENV_HOME/cache" \
    "$DEV_ENV_HOME/lib" \
    "$DEV_ENV_HOME/share" \
    "$DEV_ENV_HOME/source" \
    "$DEV_ENV_HOME/state"

  dev_env_install_runtime_config "$DEV_ENV_HOME" "$source_root"

  rm -rf "${DEV_ENV_HOME:?}/bin"
  mkdir -p "$DEV_ENV_HOME/bin"
  for source_bin in "$source_root/bin"/*; do
    [ -e "$source_bin" ] || continue
    cp -a "$source_bin" "$DEV_ENV_HOME/bin/$(basename "$source_bin")"
    chmod u+x "$DEV_ENV_HOME/bin/$(basename "$source_bin")" 2>/dev/null || true
  done

  mkdir -p "$HOME/.local/bin"
  cat > "$HOME/.local/bin/dev-env" <<EOF
#!/usr/bin/env sh
exec "\${DEV_ENV_HOME:-\$HOME/.local/share/dev-env}/bin/dev-env" "\$@"
EOF
  chmod u+x "$HOME/.local/bin/dev-env" 2>/dev/null || true

  rm -rf "${DEV_ENV_HOME:?}/lib"
  mkdir -p "$DEV_ENV_HOME/lib"
  if [ -d "$source_root/lib" ]; then
    cp -a "$source_root/lib/." "$DEV_ENV_HOME/lib/"
  fi

  printf 'installed dev-env config from %s to %s\n' "$source_root" "$DEV_ENV_HOME"
}
