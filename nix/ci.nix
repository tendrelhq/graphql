{
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

    packages = {
      default = let
        pkg = lib.importJSON ../packages/server/package.json;
        pname = lib.replaceStrings ["@"] [""] pkg.name;

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
            bun server:install --frozen-lockfile --ignore-scripts --no-cache --no-progress
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out/node_modules
            mv node_modules $out/
            runHook postInstall
          '';

          outputHash =
            if pkgs.system == "aarch64-linux"
            then "sha256-O824ouH5/CB6k8wtOKxuzC7+64asI7vf8fSMSwzhYi8="
            else "sha256-f3sMiuMoFH4HJvvSXq7UTU93CYcD6UY1bqOHE5gLrzg=";
          outputHashAlgo = "sha256";
          outputHashMode = "recursive";
        };

        entrypoint = pkgs.stdenv.mkDerivation {
          inherit pname;
          inherit (pkg) version;
          src = pkgs.nix-gitignore.gitignoreSource [../.dockerignore] ../.;

          nativeBuildInputs = with pkgs; [bun nodejs node_modules];

          dontFixup = true; # patchShebangs produces illegal path references in FODs

          configurePhase = ''
            runHook preConfigure
            cp -a ${node_modules}/node_modules ./node_modules
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
            cp ./packages/server/out/app $out/bin/entrypoint
            runHook postInstall
          '';

          meta.mainProgram = "entrypoint"; # so you can `nix run`
        };

        healthcheck = pkgs.writeShellApplication {
          name = "healthcheck";
          runtimeInputs = [pkgs.curl];
          text = ''
            curl -I http://localhost:4000/live
          '';
        };
      in
        pkgs.symlinkJoin {
          name = "graphql";
          paths = [
            healthcheck
            entrypoint
          ];
          passthru = {inherit node_modules;};
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
