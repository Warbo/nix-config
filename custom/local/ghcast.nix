{ stdenv, haskellPackages }:

let

# A version of GHC with AstPlugin in its database
ghcWithPlugin = haskellPackages.ghcWithPackages (hs: [ hs.AstPlugin ]);

# The database used by ghcWithPlugin
ghcDb = "${ghcWithPlugin}/lib/${haskellPackages.ghc.name}/package.conf.d";

in stdenv.mkDerivation {
  name = "ghc-with-astplugin";
  version = haskellPackages.ghc.version;

  ghcScript = ''
    #!/usr/bin/env bash
    echo "Compiling with AST plugin enabled" >> /dev/stderr
    ${ghcWithPlugin}/bin/ghc -package-db=${ghcDb} -fplugin=AstPlugin.Plugin "$@"
    # -this-package-key=main  -package AstPlugin
  '';

  buildCommand = ''
    source $stdenv/setup

    # Put our wrapper in place of ghc
    mkdir -p "$out/bin"
    echo "$ghcScript" > "$out/bin/ghc"
    chmod +x "$out/bin/ghc"

    # Defer any other programs to the regular GHC versions
    for PROG in ${ghcWithPlugin}/bin/* #*/
    do
        NAME=$(basename "$PROG")
        [[ "x$NAME" = "xghc" ]] && continue
        ln -vs "$PROG" "$out/bin/$NAME"
    done
  '';

  # Inherit meta info from GHC (e.g. which platforms we support)
  meta = haskellPackages.ghc.meta;
}
