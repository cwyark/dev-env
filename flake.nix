{
  description = "Portable terminal dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [
      "aarch64-darwin"
      "x86_64-linux"
      "aarch64-linux"
    ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        toolsets = import ./nix/toolsets.nix { inherit pkgs; };
        runtime = pkgs.buildEnv {
          name = "dev-env-runtime";
          paths = toolsets.core ++ toolsets.nvim;
          pathsToLink = [ "/bin" "/share" ];
        };
      in
      {
        packages.default = runtime;

        packages.bundle = pkgs.stdenvNoCC.mkDerivation {
          name = "dev-env-${system}-bundle";
          dontUnpack = true;
          installPhase = ''
            mkdir -p "$out"
            mkdir -p root/bin root/etc/fish root/share/dev-env
            cp -R ${runtime}/bin root/
            cp -R ${./bin}/* root/bin/
            cp -R ${./lib} root/lib
            cp -R ${./scripts} root/scripts
            cp -R ${./chezmoi} root/chezmoi
            cp -R ${./runtime/etc/fish}/* root/etc/fish/
            cp -R ${./bin} root/share/dev-env/bin-src
            cp -R ${./lib} root/share/dev-env/lib
            cp -R ${./scripts} root/share/dev-env/scripts
            cp -R ${./chezmoi} root/share/dev-env/chezmoi
            cp -R ${./runtime} root/share/dev-env/runtime
            chmod +x root/bin/* root/scripts/* root/share/dev-env/scripts/* || true
            tar -C root -czf "$out/dev-env-${system}.tar.gz" .
          '';
        };

        devShells.default = pkgs.mkShell {
          packages = toolsets.core ++ toolsets.nvim ++ toolsets.packaging;
          shellHook = ''
            export DEV_ENV_REPO="$PWD"
            export DEV_ENV_HOME="''${DEV_ENV_HOME:-$HOME/.local/share/dev-env}"

            if [ -z "''${DEV_ENV_NIX_SHELL_ACTIVE:-}" ]; then
              export DEV_ENV_NIX_SHELL_ACTIVE=1
              if [ "''${DEV_ENV_QUIET:-0}" != "1" ]; then
                printf 'dev-env: entered nix shell (%s)\n' "${system}"
              fi
              dev_env_exit_hook() {
                if [ "''${DEV_ENV_QUIET:-0}" != "1" ]; then
                  printf 'dev-env: exited nix shell (%s)\n' "${system}"
                fi
              }
              trap dev_env_exit_hook EXIT
            fi
          '';
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
