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
        copyVersionToRoot =
          if builtins.pathExists ./VERSION
          then "cp -a ${./VERSION} root/VERSION"
          else "";
        copyVersionToOut =
          if builtins.pathExists ./VERSION
          then ''cp -a ${./VERSION} "$out/VERSION"''
          else "";
        copyNodeVersionToRoot =
          if builtins.pathExists ./.node-version
          then "cp -a ${./.node-version} root/.node-version"
          else "";
        copyNodeVersionToOut =
          if builtins.pathExists ./.node-version
          then ''cp -a ${./.node-version} "$out/.node-version"''
          else "";
        toolRuntime = pkgs.buildEnv {
          name = "dev-env-runtime";
          paths = toolsets.core ++ toolsets.nvim;
          # Git stores its remote helpers under libexec/git-core; Neovim's
          # plugin bootstrap needs git-remote-https to be present.
          pathsToLink = [ "/bin" "/lib" "/libexec" "/share" ];
        };
        devEnvFiles = pkgs.stdenvNoCC.mkDerivation {
          name = "dev-env-files";
          dontUnpack = true;
          installPhase = ''
            mkdir -p \
              "$out/bin" \
              "$out/lib" \
              "$out/chezmoi" \
              "$out/share/dev-env/etc/fish" \
              "$out/share/dev-env/source"

            cp -a ${./bin}/. "$out/bin/"
            cp -a ${./lib}/. "$out/lib/"
            cp -a ${./chezmoi}/. "$out/chezmoi/"
            cp -a ${./runtime/etc/fish}/. "$out/share/dev-env/etc/fish/"

            ${copyNodeVersionToOut}
            cp -a ${./bin}/. "$out/share/dev-env/source/bin/"
            cp -a ${./lib}/. "$out/share/dev-env/source/lib/"
            cp -a ${./chezmoi}/. "$out/share/dev-env/source/chezmoi/"
            cp -a ${./runtime}/. "$out/share/dev-env/source/runtime/"
            cp -a ${./.node-version} "$out/share/dev-env/source/.node-version"

            ${copyVersionToOut}

            chmod -R u+rwX "$out"
            find "$out/bin" -type f -exec chmod u+x {} +
          '';
        };
        runtime = pkgs.buildEnv {
          name = "dev-env-runtime";
          paths = toolsets.core ++ toolsets.nvim ++ [ devEnvFiles ];
          pathsToLink = [ "/bin" "/lib" "/libexec" "/share" "/chezmoi" ];
        };
      in
      {
        packages.default = runtime;
        packages.bundle = pkgs.stdenvNoCC.mkDerivation {
          name = "dev-env-${system}-bundle";
          dontUnpack = true;
          nativeBuildInputs = [
            pkgs.file
            pkgs.findutils
            pkgs.gnugrep
            pkgs.gnutar
            pkgs.gzip
          ];
          installPhase = ''
            mkdir -p "$out"
            mkdir -p \
              root/bin \
              root/cache \
              root/config \
              root/lib \
              root/libexec \
              root/etc/fish \
              root/share/dev-env \
              root/share/dev-env/source \
              root/share/dev-env/reports \
              root/state
            : > root/.dev-env-root

            cp -aL ${toolRuntime}/bin/. root/bin/
            cp -aL ${toolRuntime}/lib/. root/lib/
            cp -aL ${toolRuntime}/libexec/. root/libexec/
            cp -aL ${toolRuntime}/share/. root/share/
            chmod u+w root/bin root/lib root/libexec root/share

            for src in ${./bin}/*; do
              name="$(basename "$src")"
              if [ -e "root/bin/$name" ]; then
                printf 'error: bin collision while bundling: %s\n' "$name" >&2
                exit 1
              fi
            done

            cp -a ${./bin}/. root/bin/
            cp -a ${./lib}/. root/lib/
            cp -a ${./scripts}/. root/scripts/
            cp -a ${./chezmoi}/. root/chezmoi/
            cp -a ${./runtime/etc/fish}/. root/etc/fish/
            ${copyNodeVersionToRoot}

            cp -a ${./bin}/. root/share/dev-env/source/bin/
            cp -a ${./lib}/. root/share/dev-env/source/lib/
            cp -a ${./scripts}/. root/share/dev-env/source/scripts/
            cp -a ${./chezmoi}/. root/share/dev-env/source/chezmoi/
            cp -a ${./runtime}/. root/share/dev-env/source/runtime/
            cp -a ${./.node-version} root/share/dev-env/source/.node-version

            ${copyVersionToRoot}

            chmod -R u+rwX root
            find root/bin root/scripts root/share/dev-env/source/scripts -type f -exec chmod u+x {} +

            store_refs_report="root/share/dev-env/reports/nix-store-references.txt"
            if grep -RIl '/nix/store' root > "$store_refs_report"; then
              printf 'warning: bundle still contains /nix/store references; see share/dev-env/reports/nix-store-references.txt\n' >&2
            else
              : > "$store_refs_report"
            fi

            dynamic_files_report="root/share/dev-env/reports/file-types.txt"
            find root/bin root/libexec -type f -perm -u+x -exec file {} + > "$dynamic_files_report"

            tar \
              --sort=name \
              --mtime='UTC 1970-01-01' \
              --owner=0 \
              --group=0 \
              --numeric-owner \
              -C root \
              -czf "$out/dev-env-${system}.tar.gz" .
          '';
        };

        devShells.default = pkgs.mkShell {
          packages = toolsets.core ++ toolsets.nvim;
          shellHook = ''
            export DEV_ENV_REPO="$PWD"
            export DEV_ENV_ROOT="''${DEV_ENV_ROOT:-$PWD}"
            export DEV_ENV_HOME="''${DEV_ENV_HOME:-$HOME/.local/share/dev-env}"

            . ${./lib/node-tools.sh}
            . ${./lib/bun-tools.sh}
            dev_env_use_fnm_node || true
            dev_env_activate_bun
            dev_env_ensure_bun_tools || true
          '';
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
