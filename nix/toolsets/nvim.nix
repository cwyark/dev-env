{ pkgs }:

let
  optionalPackage = name:
    if builtins.hasAttr name pkgs then [ (builtins.getAttr name pkgs) ] else [ ];

  toolsets = with pkgs; {
    languageServers = [
      lua-language-server
      rust-analyzer
      clang-tools
      pyright
      zls
      taplo
    ] ++ optionalPackage "neocmakelsp";

    formattersAndLinters = [
      ruff
      biome
    ];

    debuggers =
      optionalPackage "codelldb"
      ++ optionalPackage "bash-debug-adapter"
      ++ optionalPackage "debugpy";

    tooling = [
      opencode
      tree-sitter
    ];
  };
in
builtins.concatLists [
  toolsets.languageServers
  toolsets.formattersAndLinters
  toolsets.debuggers
  toolsets.tooling
]
