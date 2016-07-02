self: super:

with self;
with builtins;

let tipSrc = fetchgit {
      url    = https://github.com/tip-org/tools.git;
      rev    = "6ded3a8"; # Version 0.2.2
      sha256 = "1ibf0gd2wig58a20r3jaj3yiqxi981f75fcsss5czwnk9p9yv3vb";
    };
    withParser = readFile (runCommand
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
 in nixFromCabal "${withParser}/tip-lib" null
