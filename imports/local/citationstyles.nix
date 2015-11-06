{ stdenv, latestGit, jre }:

stdenv.mkDerivation rec {
  name = "citation-styles";
  src = latestGit { url = https://github.com/citation-style-language/styles.git; };

  installPhase = ''
    unzip "$src"

    mkdir -p "$out/bin"
    mkdir -p "$out/lib"
    mkdir -p "$out/share/ditaa"

    cp *.jar "$out/lib/"
    cp COPYING HISTORY "$out/share/ditaa"

    cat > "$out/bin/ditaaeps" << EOF
    #!${stdenv.shell}
    ITEMP=$(mktemp "/tmp/ditaaepsXXXXX.dit")
    OTEMP=$(mktemp "/tmp/ditaaepsXXXXX.eps")
    cat > "$ITEMP"
    exec ${jre}/bin/java -jar "$out/lib/DitaaEps.jar" "\$@" "$ITEMP" "$OTEMP"
    cat "$OTEMP"
    rm "$ITEMP" "$OTEMP"
    EOF

    chmod a+x "$out/bin/ditaaeps"
  '';
}
