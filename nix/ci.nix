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
      pkg = lib.importJSON ../package.json;
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
          bun generate
          runHook postConfigure
        '';

        buildPhase = ''
          runHook preBuild
          bun run build
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          cp app $out/bin/entrypoint
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
          bun install --no-cache --no-progress --frozen-lockfile --ignore-scripts
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out/node_modules
          mv node_modules $out/
          runHook postInstall
        '';

        outputHash = "sha256-zjanMovkx8A8M7ds7Fdw2FpJ5M6XZX4pZApSXrCWj7s=";
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
      };

      postgrest = pkgs.writeShellApplication {
        name = "postgrest";
        runtimeInputs = [pkgs.postgrest];
        text = ''
          postgrest ${../config/postgrest.conf}
        '';
      };
    };
  };
}
