{ cmake, fetchurl, findutils, nixpkgs1603, stdenv }:

with { inherit (nixpkgs1603) kde4; };
stdenv.mkDerivation {
  name    = "skulpture";
  version = "0.2.4";
  src     = fetchurl {
    url    = "http://skulpture.maxiom.de/releases/skulpture-0.2.4.tar.gz";
    sha256 = "1s27xqd32ck09r1nnjp1pyxwi0js7a7rg2ppkvq2mk78nfcl6sk0";
  };

  buildInputs = [ cmake kde4.kdelibs findutils ];

  installPhase = ''
    cd ..

    mkdir -p "$out/share/doc"
    for DOC in README AUTHORS COPYING NEWS NOTES BUGS
    do
        cp -v "$DOC" "$out/share/doc/"
    done

    mkdir -p "$out/share/kde4/apps/"
    cp -rv color-schemes "$out/share/kde4/apps/"

    while read -r PAIR
    do
      F=$(echo "$PAIR" | cut -f 1)
      D=$(echo "$PAIR" | cut -f 2)
      mkdir -p "$out/$D"
      FOUND=0
      while read -r GOT
      do
        cp -rv "$GOT" "$out/$D/"
        FOUND=1
      done < <(find . -name "$F")
      [[ "$FOUND" -eq 1 ]] || exit 1
    done << EOF
    skulpture.themerc	share/kde4/apps/kstyle/themes
    skulpture.desktop	share/kde4/apps/kwin
    skulpture.png	share/kde4/apps/skulpture/pics
    skulptureui.rc	share/kde4/apps/skulpture
    libskulpture.so	lib/qt4/plugins/styles
    EOF
  '';
}
