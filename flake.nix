{
  description = "RSR";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      with import nixpkgs { inherit system; };
      let
        R-with-my-packages = rWrapper.override {
          packages = with rPackages; [
            config
            devtools
            dplyr
            keyring
            pbapply
            readr
            tidyr
          ];
        };
      in {
        devShells.default = mkShell {
          buildInputs = [ R-with-my-packages ];
          # From https://churchman.nl/tag/r/
          shellHook = ''
            mkdir -p "$(pwd)/_libs"
            export R_LIBS_USER="$(pwd)/_libs"
          '';
        };
      });

}
