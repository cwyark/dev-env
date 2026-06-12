# Managed by dev-env.

if not set -q DEV_ENV_HOME
    set -gx DEV_ENV_HOME "$HOME/.local/share/dev-env"
end

if not set -q DEV_ENV_ROOT
    set -gx DEV_ENV_ROOT "$DEV_ENV_HOME"
end

if not set -q DEV_ENV_ETC
    set -gx DEV_ENV_ETC "$DEV_ENV_ROOT/etc"
end

fish_add_path "$DEV_ENV_ROOT/bin" "$DEV_ENV_HOME/bin"

if not set -q XDG_CONFIG_HOME
    set -gx XDG_CONFIG_HOME "$DEV_ENV_HOME/config"
end

if not set -q XDG_DATA_HOME
    set -gx XDG_DATA_HOME "$DEV_ENV_HOME/share"
end

if not set -q XDG_CACHE_HOME
    set -gx XDG_CACHE_HOME "$DEV_ENV_HOME/cache"
end

if not set -q XDG_STATE_HOME
    set -gx XDG_STATE_HOME "$DEV_ENV_HOME/state"
end

mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_STATE_HOME"

set -l dev_env_node_version_file
for dev_env_root in "$DEV_ENV_ROOT" "$DEV_ENV_ROOT/share/dev-env/source"
    if test -r "$dev_env_root/.node-version"
        set dev_env_node_version_file "$dev_env_root/.node-version"
        break
    end
end

if test -n "$dev_env_node_version_file"
    set -l dev_env_node_version (string trim (string collect < "$dev_env_node_version_file"))

    if test -n "$dev_env_node_version"; and command -q fnm
        fnm env --use-on-cd --shell fish | source
        fnm use --install-if-missing --silent-if-unchanged "$dev_env_node_version" >/dev/null
    end
end

if not set -q EDITOR
    if set -q SSH_CONNECTION
        set -gx EDITOR vim
    else
        set -gx EDITOR nvim
    end
end

if status is-interactive
    if test -d "$DEV_ENV_ETC/fish/completions"
        set -g fish_complete_path "$DEV_ENV_ETC/fish/completions" $fish_complete_path
    end

    if command -q carapace
        set -gx CARAPACE_BRIDGES fish,bash,zsh,inshellisense
        carapace _carapace fish | source
    end

    if command -q eza
        function ls --description "List files with eza"
            command eza $argv
        end

        function l --description "List files in compact format with eza"
            command eza -1 $argv
        end

        function ll --description "List files in long format with eza"
            command eza -l --group-directories-first --icons=auto $argv
        end

        function la --description "List all files with eza"
            command eza -la --group-directories-first --icons=auto $argv
        end

        function lt --description "List files as a tree with eza"
            command eza --tree --group-directories-first --icons=auto $argv
        end
    end

    if test (uname -s) = Darwin
        function docker --description "Run docker commands through Lima on macOS"
            set -l lima_docker_socket "$HOME/.lima/default/sock/docker.sock"

            if test -S "$lima_docker_socket"; and command -q docker
                set -lx DOCKER_HOST "unix://$lima_docker_socket"
                command docker $argv
            else if command -q colima
                command colima nerdctl -- $argv
            else
                printf 'dev-env: no Lima Docker socket or lima command found\n' >&2
                return 127
            end
        end
    end

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
