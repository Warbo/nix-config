with builtins;

dir:

let pkgs  = import <nixpkgs> {};
    hsVer = pkgs.haskellPackages.ghc.version;
    hsh   = hashString "sha256" "$dir";
    nixed = pkgs.stdenv.mkDerivation {
      inherit dir;
      name         = "nixFromCabal-${hsVer}-${hsh}";
      buildInputs  = [ pkgs.haskellPackages.cabal2nix ];
      buildCommand = ''
        source $stdenv/setup

        echo "Copying '$dir' to '$out'"
        cp -vr "$dir" "$out"

        echo "Looking for Cabal files in '$out'"
        cd "$out"

        echo "Creating '$out/default.nix'"
        chmod +w . # We need this if dir has come from the store
        touch default.nix
        cabal2nix ./. > default.nix
      '';
    };
 in import "${nixed}"
