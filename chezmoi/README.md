# chezmoi Source

This directory is the chezmoi source state.

Apply it from the repo root with:

```sh
chezmoi --source ./chezmoi apply
```

This scaffold intentionally does not import your existing real dotfiles yet.
Import them deliberately after deciding which files should be shared unchanged
and which files need templates.

Recommended first imports:

```sh
chezmoi --source ./chezmoi add ~/.config/fish/conf.d/dev-env.fish
chezmoi --source ./chezmoi add ~/.config/zellij
chezmoi --source ./chezmoi add ~/.config/yazi
chezmoi --source ./chezmoi add ~/.config/lazygit
```

For Neovim, consider either:

- import `~/.config/nvim` directly if it is meant to be identical everywhere
- keep it as a separate Git repo and let dev-env clone/sync it
- template only small environment-sensitive files
