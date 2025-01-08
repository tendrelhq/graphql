{
  inputs = {
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://tendrelhq.cachix.org"
    ];
    extra-trusted-public-keys = [
      "tendrelhq.cachix.org-1:uAnm9wwXD60bKJbPuDgpVMxcAje1IqhKoroTi4iX608="
    ];
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devenv.flakeModule
        inputs.treefmt.flakeModule
      ];
      systems = ["x86_64-linux"];
      perSystem = {
        config,
        lib,
        pkgs,
        self',
        ...
      }: {
        devenv.shells.default = {
          name = "tendrel-graphql";
          containers = lib.mkForce {};
          env = {
            BIOME_BINARY = lib.getExe config.packages.biome;
            # TODO: switch to dev, but I need to get a self contained test
            # environment up and running first :/
            PGDATABASE = "postgres";
          };
          packages = with pkgs;
          with config.packages; [
            act
            awscli2
            biome
            bun
            copilot-cli
            just
            nodejs # required by biome's entrypoint
            perlPackages.TAPParserSourceHandlerpgTAP # pg_prove
            postgres
            sqitchPg
            squawk
            vtsls
            config.treefmt.build.wrapper
          ];
          pre-commit.hooks.treefmt = {
            enable = true;
            package = config.treefmt.build.wrapper;
          };
          processes = {
            app.exec = "bun --inspect ./bin/app.ts";
            iql.exec = "bunx ruru@beta -Pe http://localhost:4000";
            pgweb.exec = lib.getExe pkgs.pgweb;
          };
          services.postgres = {
            enable = true;
            extensions = exts:
              with exts;
              with config.packages; [
                pg_cron
                pgddl
                pgtap
                plpgsql_check
              ];
            initialDatabases = [
              {
                name = "dev";
              }
            ];
            initialScript = ''
              CREATE EXTENSION IF NOT EXISTS ddlx SCHEMA pg_catalog;
            '';
            listen_addresses = "127.0.0.1";
            package = config.packages.postgres;
            port = 5432;
            settings = {
              log_statement = "all";
              logging_collector = false;
              shared_preload_libraries = "pg_cron,plpgsql_check";
            };
          };
        };

        packages = {
          biome = let
            pkg = lib.importJSON ./package.json;
          in
            pkgs.stdenv.mkDerivation rec {
              pname = "biome";
              version = let
                v = pkg.devDependencies."@biomejs/biome";
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

          pgddl = pkgs.stdenv.mkDerivation rec {
            name = "pgddl";
            version = "0.28";
            src = pkgs.fetchFromGitHub {
              owner = "lacanoid";
              repo = name;
              rev = version;
              hash = "sha256-SWAdb2hZusDGLtB240MH15XbUm2LI/Z335TZjZIjw/s=";
            };
            buildInputs = with pkgs; [perl config.packages.postgres];
            postPatch = ''
              patchShebangs .
            '';
            installPhase = ''
              install -D -t $out/share/postgresql/extension *.sql
              install -D -t $out/share/postgresql/extension *.control
            '';
          };

          postgres = pkgs.postgresql_16;
        };

        treefmt.config = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            biome = {
              enable = true;
              package = config.packages.biome;
              includes = ["*.graphql" "*.json" "*.ts"];
            };
            prettier = {
              enable = true;
              includes = ["*.md" "*.yaml" "*.yml"];
            };
          };
          settings.formatter.biome.options = lib.mkForce ["check" "--write"];
        };
      };
    };
}
