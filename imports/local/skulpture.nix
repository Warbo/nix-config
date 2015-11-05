{ fetchurl, stdenv, cmake, kde4 }:

stdenv.mkDerivation {
  name    = "skulpture";
  version = "0.2.4";
  src     = fetchurl {
    url    = "http://kde-look.org/CONTENT/content-files/59031-skulpture-0.2.4.tar.gz";
    sha256 = "1s27xqd32ck09r1nnjp1pyxwi0js7a7rg2ppkvq2mk78nfcl6sk0";
  };

  buildInputs = [ cmake kde4.kdelibs ];

  # FIXME: file cannot create directory: /nix/store/ry6j4nf89niqg7g5aysqf6s5isn2wjxx-qt-4.8.7/lib/qt4/plugins/styles.
  # Maybe we can extend QT_PLUGIN_PATH instead?
}
