{inputs, ...}: {
  imports = [
    inputs.git-hooks.flakeModule
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    config,
    self',
    pkgs,
    lib,
    ...
  }: {
    devShells = {
      default = pkgs.mkShellNoCC {
        name = "tendrelhq/graphql";
        inputsFrom = [
          config.devShells.postgres
          config.pre-commit.devShell
        ];
        buildInputs = [
          config.packages.copilot-cli
          pkgs.awscli2
          pkgs.bun
          pkgs.just
          pkgs.nodejs
          pkgs.openssl
          pkgs.vtsls
        ];
        BIOME_BINARY = lib.getExe config.packages.biome;
        # Janky af I know, but an easy way to silently fail successfully
        TREEFMT = "treefmt";
      };
    };

    packages = {
      biome = let
        pkgJSON = lib.importJSON ../package.json;
      in
        pkgs.stdenv.mkDerivation rec {
          pname = "biome";
          version = let
            v = pkgJSON.devDependencies."@biomejs/biome";
          in "v${lib.strings.removePrefix "^" v}";

          src = pkgs.fetchurl {
            url = "https://github.com/biomejs/biome/releases/download/cli%2F${version}/biome-linux-x64";
            hash = "sha256-ziR/tkSZnvUuURHdb9bkcQGWafycSkS1aZch45twMsM=";
          };

          nativeBuildInputs = [pkgs.autoPatchelfHook];
          buildInputs = [pkgs.stdenv.cc.cc.libgcc];

          dontUnpack = true;
          installPhase = ''
            install -D -m755 $src $out/bin/biome
          '';

          meta.mainProgram = "biome";
        };

      copilot-cli = pkgs.stdenv.mkDerivation rec {
        pname = "copilot-cli";
        version = "1.33.3";
        src = pkgs.fetchurl {
          url = "https://github.com/aws/copilot-cli/releases/download/v${version}/copilot-linux";
          hash = "sha256-Igr6JQzy6C2F8tzAZwaCw3Gnkny+LtFogyvaZ8eKDhA=";
        };
        sourceRoot = ".";
        nativeBuildInputs = with pkgs; [autoPatchelfHook];
        dontUnpack = true;
        dontBuild = true;
        installPhase = ''
          runHook preInstall
          install -D -m755 $src $out/bin/copilot
          runHook postInstall
        '';
      };
    };

    pre-commit.settings = {
      hooks = {
        treefmt = {
          enable = true;
          package = config.treefmt.build.wrapper;
        };
      };
    };

    treefmt.config = {
      projectRootFile = "flake.nix";
      programs = {
        alejandra.enable = true;
        biome = {
          enable = true;
          package = config.packages.biome;
          includes = ["*.graphql" "*.json" "*.md" "*.ts"];
        };
        prettier = {
          enable = true;
          includes = ["*.yaml" "*.yml"];
        };
        shfmt.enable = true;
      };
      settings = {
        # formatter.sqlfmt = {
        #   command = lib.getExe pkgs.python3.pkgs.sqlfmt;
        #   options = ["-"];
        #   includes = ["*.sql"];
        #   excludes = ["sql/unmanaged/*.sql"];
        # };
        global.excludes = [
          "*.conf"
          "*.dockerfile"
          "*.http"
          "*.lockb"
          "*.plan"
          "*.snap"
          "*.sql"
          "*.toml"
          ".*" # hidden files
          "copilot/.workspace"
          "justfile"
          "tests-to-fix.txt"
        ];
      };
    };
  };
}
