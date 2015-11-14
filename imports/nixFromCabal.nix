with import <nixpkgs> {};
with builtins;

dir:

let nixed = stdenv.mkDerivation {
  inherit dir;
  name         = "nixFromCabal-${hashString "sha256" "$dir"}";
  buildInputs  = [ cabal2nix ];
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
