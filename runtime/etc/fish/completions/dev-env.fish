function __dev_env_needs_command
    set -l tokens (commandline -opc)
    set -e tokens[1]

    for token in $tokens
        switch $token
            case '-h' '--help' '--version' '-V'
                return 1
            case '*'
                return 1
        end
    end

    return 0
end

complete -c dev-env -f
complete -c dev-env -s h -l help -d 'Show help'
complete -c dev-env -s V -l version -d 'Print dev-env version'

complete -c dev-env -n '__dev_env_needs_command' -a version -d 'Print dev-env version'
complete -c dev-env -n '__dev_env_needs_command' -a doctor -d 'Check expected tools'
complete -c dev-env -n '__dev_env_needs_command' -a platform -d 'Print detected platform'
complete -c dev-env -n '__dev_env_needs_command' -a shell -d 'Start the isolated fish shell'
complete -c dev-env -n '__dev_env_needs_command' -a zellij -d 'Start zellij in the activated environment'
complete -c dev-env -n '__dev_env_needs_command' -a btop -d 'Start btop in the activated environment'
complete -c dev-env -n '__dev_env_needs_command' -a nvim -d 'Start neovim in the activated environment'
complete -c dev-env -n '__dev_env_needs_command' -a yazi -d 'Start yazi in the activated environment'
complete -c dev-env -n '__dev_env_needs_command' -a chezmoi-apply -d 'Apply chezmoi source from this repo'

complete -c dev-env -n '__fish_seen_subcommand_from nvim yazi' -F
