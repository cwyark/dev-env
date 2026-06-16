export DEV_ENV_HOME="${DEV_ENV_HOME:-$HOME/.local/share/dev-env}"
export PATH="$DEV_ENV_HOME/bin:$PATH"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$DEV_ENV_HOME/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$DEV_ENV_HOME/cache}"

case "$(uname -s 2>/dev/null || true):$(uname -m 2>/dev/null || true)" in
  Darwin:arm64|Darwin:aarch64)
    export DEV_ENV_PROFILE="local-macos"
    ;;
  Linux:x86_64|Linux:aarch64|Linux:arm64)
    export DEV_ENV_PROFILE="remote-linux"
    ;;
esac
