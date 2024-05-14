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
        lib,
        pkgs,
        self',
        ...
      }: {
        devenv.shells.default = {
          name = "tendrel-graphql";
          containers = lib.mkForce {};
          env.BIOME_BINARY = lib.getExe pkgs.biome;
          packages = with pkgs; [
            awscli2
            biome
            bun
            just
            postgresql
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
        };

        packages.default = self'.devShells.default;
      };
    };
}
