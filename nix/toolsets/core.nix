{ pkgs }:

let
  optionalPackage = name:
    if builtins.hasAttr name pkgs then [ (builtins.getAttr name pkgs) ] else [ ];

  toolsets = with pkgs; {
    shell = [
      fish
      zellij
    ];

    editor = [
      neovim
    ];

    versionControl = [
      git
      lazygit
    ];

    searchAndNavigation = [
      ripgrep
      fd
      fzf
      yazi
      eza
    ];

    system = [
      btop
      jq
      curl
      rsync
      openssh
      sshfs
      zstd
    ];

    development = [
      cmake
      fnm
      uv
      zig
      cargo
      carapace
    ];

    containers =
      optionalPackage "docker-client";
  };
in
builtins.concatLists [
  toolsets.editor
  toolsets.shell
  toolsets.versionControl
  toolsets.development
  toolsets.searchAndNavigation
  toolsets.system
  toolsets.containers
]
