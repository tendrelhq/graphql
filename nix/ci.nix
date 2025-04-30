{inputs, ...}: {
  perSystem = {
    config,
    self',
    pkgs,
    lib,
    ...
  }: {
    devShells = {
      ci = pkgs.mkShellNoCC {
        name = "tendrelhq/graphql-ci";
        inputsFrom = [
          config.devShells.default
        ];
        TREEFMT = "treefmt";
      };
    };

    packages = let
      pkg = lib.importJSON ../packages/server/package.json;
      pname = lib.replaceStrings ["@"] [""] pkg.name;
    in {
      default = pkgs.stdenv.mkDerivation {
        inherit pname;
        inherit (pkg) version;
        src = pkgs.nix-gitignore.gitignoreSource [../.dockerignore] ../.;

        nativeBuildInputs = with pkgs; [bun nodejs config.packages.node_modules];

        dontFixup = true; # patchShebangs produces illegal path references in FODs

        configurePhase = ''
          runHook preConfigure
          cp -a ${config.packages.node_modules}/node_modules ./node_modules
          chmod -R u+rw node_modules
          chmod -R u+x node_modules/.bin
          patchShebangs node_modules
          export PATH="$PWD/node_modules/.bin:$PATH"
          bun server:generate
          runHook postConfigure
        '';

        buildPhase = ''
          runHook preBuild
          bun server:build
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          cp ./packages/server/app $out/bin/entrypoint
          runHook postInstall
        '';

        meta.mainProgram = "entrypoint"; # so you can `nix run`
      };

      node_modules = pkgs.stdenv.mkDerivation {
        pname = "${pname}-deps";
        inherit (pkg) version;
        src = pkgs.nix-gitignore.gitignoreSource [../.dockerignore] ../.;

        nativeBuildInputs = [pkgs.bun];

        dontConfigure = true;
        dontFixup = true; # patchShebangs produces illegal path references in FODs

        buildPhase = ''
          runHook preBuild
          export HOME=$TMPDIR
          bun install --ignore-scripts --frozen-lockfile --no-cache --no-progress --filter ./packages/server
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out/node_modules
          mv node_modules $out/
          runHook postInstall
        '';

        # TODO: Not sure what is causing these to differ.
        # Regardless, soon to be fixed via: https://github.com/NixOS/nixpkgs/issues/335534
        # Huh. It fixed itself. Lmao.
        # outputHash =
        #   if pkgs.system == "aarch64-linux"
        #   then "sha256-j1DhYYPic49ZZIPHTq/H7lb7nsAqj46CESquC+WkZUM="
        #   else "sha256-j1DhYYPic49ZZIPHTq/H7lb7nsAqj46CESquC+WkZUM=";
        outputHash = "sha256-j1DhYYPic49ZZIPHTq/H7lb7nsAqj46CESquC+WkZUM=";
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
      };

      postgrest = let
        healthcheck = pkgs.writeShellApplication {
          name = "healthcheck";
          runtimeInputs = [pkgs.curl];
          text = ''
            curl -I http://localhost:4002/live
          '';
        };
        entrypoint = pkgs.writeShellApplication {
          name = "entrypoint";
          runtimeInputs = [pkgs.postgrest];
          text = ''
            postgrest ${../config/postgrest.conf}
          '';
        };
      in
        pkgs.symlinkJoin {
          name = "postgrest";
          paths = [
            healthcheck
            entrypoint
          ];
        };
    };
  };
}
