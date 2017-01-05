self: super:

with self;
with builtins;

let withParser = import (runCommand
      "mk-parser"
      {
        buildInputs = [ haskellPackages.BNFC nix gcc ];
        NIX_REMOTE  = "daemon";
        NIX_PATH    = getEnv "NIX_PATH";
      }
      ''
        cp -r "${tipSrc}" ./tip
        chmod -R +w ./tip
        pushd ./tip
        bash make_parser.sh
        ln -s $(gcc --print-file-name=libstdc++.so)
        pushd tip-lib
        ln -s $(gcc --print-file-name=libstdc++.so)
        popd
        popd
        RESULT=$(nix-store --add tip)
        printf "%s" "$RESULT" > "$out"
      '');
    parserSrc = stdenv.mkDerivation {
      name = "tip-lib-with-parser";
      src  = withParser;
      buildCommand = ''
        source $stdenv/setup

        cp -ar "$src/tip-lib" "$out"
      '';
    };
 in nixFromCabal parserSrc null
