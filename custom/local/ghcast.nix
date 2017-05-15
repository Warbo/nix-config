{ haskellPackages, makeWrapper, stdenv, tincify, writeScript }:

with rec {
  # A version of GHC with AstPlugin in its database
  ghcWithPlugin = tincify (haskellPackages.AstPlugin // {
                            extras = [ "HS2AST" ];
                            includeExtras = true;
                          });

  # The database used by ghcWithPlugin
  ghcDb = "${ghcWithPlugin}/lib/${haskellPackages.ghc.name}/package.conf.d";
};

stdenv.mkDerivation {
  name    = "ghc-with-astplugin";
  version = haskellPackages.ghc.version;

  ghcScript = writeScript "ghcScript" ''
    #!/usr/bin/env bash
    echo "Compiling with AST plugin enabled" 1>&2
    "${ghcWithPlugin}/bin/ghc" -package-db=${ghcDb} \
                               -fplugin=AstPlugin.Plugin "$@"
    # -this-package-key=main  -package AstPlugin
  '';

  buildInputs  = [ makeWrapper ];
  buildCommand = ''
    source $stdenv/setup
    mkdir -p "$out/bin"

    # Wrap all of GHC's provided programs
    for PROG in ${ghcWithPlugin}/bin/* #*/
    do
      NAME=$(basename "$PROG")
      makeWrapper "$PROG" "$out/bin/$NAME" \
        --prefix PATH : "${ghcWithPlugin}/bin" \
        --prefix PATH : "$out/bin"
    done

    # Put our wrapper in place of ghc
    rm "$out/bin/ghc"
    makeWrapper "$ghcScript" "$out/bin/ghc" \
      --prefix PATH : "${ghcWithPlugin}/bin"
  '';

  # Inherit meta info from GHC (e.g. which platforms we support)
  meta = haskellPackages.ghc.meta;
}
