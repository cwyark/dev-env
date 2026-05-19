{ pkgs }:

let
  optionalPackage = name:
    if builtins.hasAttr name pkgs then [ (builtins.getAttr name pkgs) ] else [ ];

  darwinOptionalPackage = name:
    if pkgs.stdenv.isDarwin && builtins.hasAttr name pkgs then [ (builtins.getAttr name pkgs) ] else [ ];

  dockerClient =
    if builtins.hasAttr "docker-client" pkgs then [ pkgs.docker-client ] else [ ];

  coreTools = with pkgs; [
    neovim
    yazi
    zellij
    fish
    chezmoi
    cmake
  ]
  ++ optionalPackage "codex"
  ++ (with pkgs; [
    git
    ripgrep
    fd
    fzf
    fnm
    lazygit
    btop
    eza
    carapace
    jq
    curl
    rsync
    openssh
    uv
    zstd
  ]);
in
{
  core = coreTools
    ++ dockerClient
    ++ darwinOptionalPackage "lima"
    ++ darwinOptionalPackage "colima";

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
