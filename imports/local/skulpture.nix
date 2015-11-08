{ fetchurl, stdenv, cmake, kde4, findutils }:

stdenv.mkDerivation {
  name    = "skulpture";
  version = "0.2.4";
  src     = fetchurl {
    url    = "http://kde-look.org/CONTENT/content-files/59031-skulpture-0.2.4.tar.gz";
    sha256 = "1s27xqd32ck09r1nnjp1pyxwi0js7a7rg2ppkvq2mk78nfcl6sk0";
  };

  buildInputs = [ cmake kde4.kdelibs findutils ];

  installPhase = ''
    cd ..
    pwd
    for FILE in skulpture.themerc skulpture.desktop skulpture.png skulptureui.rc \
        "Skulpture*.colors" libskulpture.so kstyle_skulpture_config.so \
        kwin3_skulpture.so kwin_skulpture_config.so
    do
        echo "Looking for '$FILE'"
        find . -name "$FILE"
    done
    mkdir -p "$out/share/doc"
    for DOC in README AUTHORS COPYING NEWS NOTES BUGS
    do
        cp "$DOC" "$out/share/doc/"
    done

    mkdir -p "$out/share/kde4/apps/kstyle/themes"
    cp src/skulpture.themerc "$out/share/kde4/apps/kstyle/themes/"

    mkdir -p "$out/share/kde4/apps/kwin"
    cp kwin-client/skulpture.desktop "$out/share/kde4/apps/kwin/"

    mkdir -p "$out/share/kde4/apps/skulpture/pics"
    cp src/config/skulpture.png "$out/share/kde4/apps/skulpture/pics/"

    mkdir -p "$out/share/kde4/apps/skulpture"
    cp src/config/skulptureui.rc "$out/share/kde4/apps/skulpture/"

    mkdir -p "$out/share/kde4/apps"
    cp -r color-schemes "$out/share/kde4/apps/"

    mkdir -p "$out/lib/qt4/plugins/styles"
    cp build/lib/libskulpture.so "$out/lib/qt4/plugins/styles/"

    mkdir -p "$out/lib/kde4"
    cp build/lib/kstyle_skulpture_config.so "$out/lib/kde4"
  '';

  # FIXME: file cannot create directory: /nix/store/ry6j4nf89niqg7g5aysqf6s5isn2wjxx-qt-4.8.7/lib/qt4/plugins/styles.
  # Maybe we can extend QT_PLUGIN_PATH instead?
}
