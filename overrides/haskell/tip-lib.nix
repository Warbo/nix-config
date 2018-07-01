self: super:

with self;
with builtins;
with rec {
  mkParser = runCommand "mk-parser"
    {
      inherit tipSrc;
      buildInputs = [ haskellPackages.BNFC gcc ];
    }
    ''
      cp -r "$tipSrc" ./tip
      chmod -R +w ./tip
        pushd ./tip
        bash make_parser.sh
        ln -s $(gcc --print-file-name=libstdc++.so)
        pushd tip-lib
          ln -s $(gcc --print-file-name=libstdc++.so)
        popd
      popd
      cp -r tip "$out"
    '';

  parserSrc = stdenv.mkDerivation {
    name         = "tip-lib-with-parser";
    src          = mkParser;
    buildCommand = ''
      source $stdenv/setup

      cp -a "$src/tip-lib" ./tip-lib
      chmod +w -R ./tip-lib

      for F in src/Tip/Pass/Pipeline.hs src/Tip/Passes.hs executable/Main.hs
      do
        echo "Patching $F" 1>&2
        sed -e 's/\(import Options.Applicative\)/\1\nimport Data.Monoid ((<>))/' \
            < "./tip-lib/$F" > temp
        mv temp "./tip-lib/$F"
      done

      cp -a ./tip-lib "$out"
    '';
  };
};
nixFromCabal parserSrc null
