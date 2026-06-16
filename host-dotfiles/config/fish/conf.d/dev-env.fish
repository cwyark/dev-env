set -l dev_env_fish_config "$HOME/.local/share/dev-env/etc/fish/config.fish"

if test -r "$dev_env_fish_config"
    source "$dev_env_fish_config"
end
