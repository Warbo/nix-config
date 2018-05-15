{ hasBinary, fetchurl, jre, stdenv, unzip, withDeps }:

with rec {
  pkg = stdenv.mkDerivation rec {
    name = "ditaaeps-0.2";

    src = fetchurl {
      name   = "${name}.zip";
      url    = "mirror://sourceforge/project/ditaa-addons/DitaaEps/0.2/DitaaEps-0_2.zip";
      sha256 = "0c64shycl3pqfld14kbkd3bg9d53w35qy1b3mn84qbpf02wvhp66";
    };

    buildInputs = [ unzip ];

    phases = [ "installPhase" ];

    installPhase = ''
      unzip "$src"
      cd DitaaEps

      mkdir -p "$out/bin"
      mkdir -p "$out/lib"
      mkdir -p "$out/share/ditaa"

      cp *.jar "$out/lib/"
      cp README.txt "$out/share/ditaa"

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

    meta = with stdenv.lib; {
      description = "Convert ascii art diagrams into proper graphics";
      homepage = http://ditaa-addons.sourceforge.net/;
      license = licenses.gpl2;
      platforms = platforms.linux;
    };
  };

  tested = withDeps [ (hasBinary pkg "ditaaeps") ] pkg;
};
{
  pkg   =   tested;
  tests = [ tested ];
}
