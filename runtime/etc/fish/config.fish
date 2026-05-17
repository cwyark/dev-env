# Managed by dev-env.

if not set -q DEV_ENV_HOME
    set -gx DEV_ENV_HOME "$HOME/.local/share/dev-env"
end

fish_add_path "$DEV_ENV_HOME/bin"

if not set -q XDG_DATA_HOME
    set -gx XDG_DATA_HOME "$DEV_ENV_HOME/share"
end

if not set -q XDG_CACHE_HOME
    set -gx XDG_CACHE_HOME "$DEV_ENV_HOME/cache"
end

if not set -q EDITOR
    if set -q SSH_CONNECTION
        set -gx EDITOR vim
    else
        set -gx EDITOR nvim
    end
end

if status is-interactive
    alias nv nvim

    function y --description "Open yazi and cd into the chosen directory"
        set -l tmp (mktemp -t yazi-cwd.XXXXXX)
        command yazi $argv --cwd-file="$tmp"
        set -l cwd (string trim (string collect < "$tmp"))
        if test -n "$cwd"; and test "$cwd" != "$PWD"
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
end
