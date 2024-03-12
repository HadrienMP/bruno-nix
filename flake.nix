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
      brunoX8664Linux = pkgs.stdenv.mkDerivation {
        name = "bruno";
        version = "1.1.1";

        src = pkgs.fetchurl {
          url = "https://github.com/usebruno/bruno/releases/download/v${version}/bruno_${version}_amd64_linux.deb";
          hash = "sha256-lG5OMxDS7I2jmI6syWzTsHm/NEoGanilW8IPebs+/10=";
        };

        nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.dpkg pkgs.wrapGAppsHook ];

        buildInputs = [
          pkgs.alsa-lib
          pkgs.gtk3
          pkgs.mesa
          pkgs.nspr
          pkgs.nss
        ];

        runtimeDependencies = [ (pkgs.lib.getLib pkgs.systemd) ];

        installPhase = ''
          runHook preInstall
          mkdir -p "$out/bin"
          cp -R opt $out
          cp -R "usr/share" "$out/share"
          ln -s "$out/opt/Bruno/bruno" "$out/bin/bruno"
          chmod -R g-w "$out"
          runHook postInstall
        '';

        postFixup = ''
          substituteInPlace "$out/share/applications/bruno.desktop" \
            --replace "/opt/Bruno/bruno" "$out/bin/bruno"
        '';

      };
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
      brunoX8664Darwin = pkgs.stdenv.mkDerivation {
        name = "bruno";
        version = "${version}";
        src = pkgs.fetchurl {
          url = "https://github.com/usebruno/bruno/releases/download/v${version}/bruno_${version}_x64_mac.zip";
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

      packages."aarch64-darwin".bruno = brunoAarch64Darwin;
      defaultPackage."aarch64-darwin" = brunoAarch64Darwin;
      packages."x86_64-darwin".bruno = brunoX8664Darwin;
      defaultPackage."x86_64-darwin" = brunoX8664Darwin;
      packages."x86_64-linux".bruno = brunoX8664Linux;
      defaultPackage."x86_64-linux" = brunoX8664Linux;
    };
}
