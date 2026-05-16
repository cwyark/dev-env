{ pkgs }:

let
  optionalPackage = name:
    if builtins.hasAttr name pkgs then [ (builtins.getAttr name pkgs) ] else [ ];
in
{
  core = with pkgs; [
    neovim
    yazi
    zellij
    chezmoi
    git
    ripgrep
    fd
    fzf
    fnm
    lazygit
    jq
    curl
    rsync
    openssh
    uv
    zstd
  ];

  nvim = with pkgs; [
    lua-language-server
    rust-analyzer
    clang-tools
    pyright
    ruff
    biome
    taplo
    nodejs
    tree-sitter
    cargo
  ]
  ++ optionalPackage "neocmakelsp"
  ++ optionalPackage "codelldb"
  ++ optionalPackage "bash-debug-adapter"
  ++ optionalPackage "debugpy";

  packaging = with pkgs; [
    nixpkgs-fmt
    shellcheck
  ];
}
