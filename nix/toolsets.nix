{ pkgs }:

{
  core = import ./toolsets/core.nix { inherit pkgs; };
  nvim = import ./toolsets/nvim.nix { inherit pkgs; };
}
