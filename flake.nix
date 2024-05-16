{
  inputs = {
    devenv.url = "github:cachix/devenv";
    git-hooks.url = "github:cachix/git-hooks.nix";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    devenv.inputs.pre-commit-hooks.follows = "git-hooks";
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
          env.BIOME_BINARY = lib.getExe pkgs.biome;
          packages = with pkgs; [
            awscli2
            biome
            bun
            just
            cfg.services.postgres.package
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
          pre-commit.hooks = {
            alejandra.enable = true;
            biome.enable = true;
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

        packages.default = self'.devShells.default;
      };
    };
}
