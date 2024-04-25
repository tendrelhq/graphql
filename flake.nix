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
            biome
            bun
            nodejs
            nodejs.pkgs.typescript-language-server
          ];
          # environment variables
          BIOME_BINARY = lib.getExe pkgs.biome;
        };
      };
    };
}
