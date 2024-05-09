{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      perSystem = {
        lib,
        pkgs,
        ...
      }: {
        devShells.default = pkgs.mkShell {
          name = "tendrel-graphql";
          buildInputs = with pkgs; [
            awscli2
            biome
            bun
            just
            nodejs
            nodejs.pkgs.typescript-language-server
            xdg-utils
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
          # environment variables
          BIOME_BINARY = lib.getExe pkgs.biome;
        };
      };
    };
}
