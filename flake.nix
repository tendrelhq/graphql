{
  inputs = {
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks.follows = "git-hooks";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
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
        devenv.shells.default = let
          cfg = config.devenv.shells.default;
        in {
          name = "tendrel-graphql";
          containers = lib.mkForce {};
          env = {
            BIOME_BINARY = lib.getExe config.packages.biome;
          };
          packages = with pkgs; [
            act
            awscli2
            biome
            bun
            just
            nodejs # required by biome's entrypoint
            cfg.services.postgres.package
            config.treefmt.build.wrapper
            (stdenv.mkDerivation rec {
              pname = "copilot-cli";
              version = "1.33.3";
              src = fetchurl {
                url = "https://github.com/aws/copilot-cli/releases/download/v${version}/copilot-linux";
                hash = "sha256-Igr6JQzy6C2F8tzAZwaCw3Gnkny+LtFogyvaZ8eKDhA=";
              };
              sourceRoot = ".";
              nativeBuildInputs = [autoPatchelfHook];
              dontUnpack = true;
              dontBuild = true;
              installPhase = ''
                runHook preInstall
                install -D -m755 $src $out/bin/copilot
                runHook postInstall
              '';
            })
          ];
          pre-commit.hooks.treefmt = {
            enable = true;
            package = config.treefmt.build.wrapper;
          };
          processes = {
            app.exec = "bun dev";
            ruru.exec = "bun explore";
          };
          services.postgres = {
            enable = true;
            extensions = exts:
              with exts; [
                pg_cron
                pgtap
                plpgsql_check
                (pkgs.stdenv.mkDerivation rec {
                  name = "pg_ddl";
                  version = "0.27";
                  src = pkgs.fetchFromGitHub {
                    owner = "lacanoid";
                    repo = "pgddl";
                    rev = version;
                    hash = "sha256-wX2ta+oFib/XzhixIg/BHjliFK3m9Kz+2XBctYCzemE=";
                  };
                  buildInputs = with pkgs; [perl cfg.services.postgres.package];
                  postPatch = ''
                    patchShebangs .
                  '';
                  installPhase = ''
                    install -D -t $out/share/postgresql/extension *.sql
                    install -D -t $out/share/postgresql/extension *.control
                  '';
                })
              ];
            listen_addresses = "127.0.0.1";
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
        };
      };
    };
}
