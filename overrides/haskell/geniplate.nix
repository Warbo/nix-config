self: super:

with self;
with rec {
  gpSrc = fetchFromGitHub {
    owner  = "danr";
    repo   = "geniplate";
    rev    = "961a732";
    sha256 = "1ws5v1md552amcs7hhg4cla1sbq9lh3imqjiz8byvsp8bgrn4xvf";
  };

  patched = runCommand "patch-geniplate" { inherit gpSrc; } ''
    cp -r "$gpSrc" ./toPatch
    chmod 777 -R ./toPatch

    sed -e 's/geniplate-mirror/geniplate/g' < "toPatch/geniplate-mirror.cabal" \
                                            > "toPatch/geniplate.cabal"
    rm "toPatch/geniplate-mirror.cabal"

    cp -r ./toPatch "$out"
  '';
};

nixFromCabal patched null
