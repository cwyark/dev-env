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
    zellij
    fish
    chezmoi
  ]
  ++ (with pkgs; [
    git
    cmake
    ripgrep
    fd
    yazi
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
    sshfs
    uv
    zig
    zstd
    codex
    opencode
    cargo
    nodejs
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
    zls
    ruff
    biome
    taplo
    tree-sitter
  ]
  ++ optionalPackage "neocmakelsp"
  ++ optionalPackage "codelldb"
  ++ optionalPackage "bash-debug-adapter"
  ++ optionalPackage "debugpy";

}
