export DEV_ENV_HOME="${DEV_ENV_HOME:-$HOME/.local/share/dev-env}"
export PATH="$DEV_ENV_HOME/bin:$HOME/.local/bin:$PATH"
export XDG_CONFIG_HOME="$DEV_ENV_HOME/config"
export XDG_DATA_HOME="$DEV_ENV_HOME/share"
export XDG_CACHE_HOME="$DEV_ENV_HOME/cache"
export XDG_STATE_HOME="$DEV_ENV_HOME/state"
export MISE_GLOBAL_CONFIG_FILE="$DEV_ENV_HOME/config/mise/config.toml"
export MISE_DATA_DIR="$DEV_ENV_HOME/share/mise"
export MISE_CACHE_DIR="$DEV_ENV_HOME/cache/mise"
export MISE_STATE_DIR="$DEV_ENV_HOME/state/mise"

case "$(uname -s 2>/dev/null || true):$(uname -m 2>/dev/null || true)" in
  Darwin:arm64|Darwin:aarch64)
    export DEV_ENV_PROFILE="macos-arm64"
    ;;
  Darwin:x86_64|Darwin:amd64)
    export DEV_ENV_PROFILE="macos-x86_64"
    ;;
  Linux:x86_64|Linux:amd64)
    export DEV_ENV_PROFILE="linux-x86_64"
    ;;
  Linux:aarch64|Linux:arm64)
    export DEV_ENV_PROFILE="linux-arm64"
    ;;
esac
