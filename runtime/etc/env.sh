export DEV_ENV_HOME="${DEV_ENV_HOME:-$HOME/.local/share/dev-env}"

case ":$PATH:" in
  *":$DEV_ENV_HOME/bin:"*) ;;
  *) export PATH="$DEV_ENV_HOME/bin:$PATH" ;;
esac

export XDG_DATA_HOME="${XDG_DATA_HOME:-$DEV_ENV_HOME/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$DEV_ENV_HOME/cache}"

case "$(uname -s 2>/dev/null):$(uname -m 2>/dev/null)" in
  Darwin:arm64)
    export DEV_ENV_PROFILE="${DEV_ENV_PROFILE:-local-macos}"
    ;;
  Linux:x86_64|Linux:amd64|Linux:aarch64|Linux:arm64)
    export DEV_ENV_PROFILE="${DEV_ENV_PROFILE:-remote-linux}"
    ;;
esac
