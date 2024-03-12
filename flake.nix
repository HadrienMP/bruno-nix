{
  description = "Opensource IDE For Exploring and Testing Api's (lightweight alternative to postman/insomnia)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages."${system}";
      version = "1.10.0";
      brunoAarch64Darwin = pkgs.stdenv.mkDerivation {
        name = "bruno";
        version = "${version}";
        src = pkgs.fetchurl {
          url = "https://github.com/usebruno/bruno/releases/download/v${version}/bruno_${version}_arm64_mac.zip";
          hash = "sha256-vCdDoY3cKpBfkS0c5MoFRmcyZ5Rs2+9U89j+DdG4ugw=";
        };

        buildInputs = [ pkgs.unzip ];

        installPhase = ''
          mkdir -p "$out/Applications/Bruno.app"
          cp -r . $out/Applications/Bruno.app
          mkdir -p "$out/bin"
          echo "#!/usr/bin/env zsh" > $out/bin/bruno
          echo "open -n $out/Applications/Bruno.app" >> $out/bin/bruno
          chmod a+x $out/bin/bruno
        '';
      };

    in
    {
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.nodejs_18
        ];
      };

      packages."${system}".bruno = brunoAarch64Darwin;
      defaultPackage."${system}" = brunoAarch64Darwin;
    };
}
