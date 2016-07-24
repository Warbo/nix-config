{ stdenv, fetchurl }:

# Linux support for Playstation Patch Files
stdenv.mkDerivation {
  name = "lppf";
  src  = fetchurl {
    url = "mirror://sourceforge/lppf/lppf-0.1-rc1.tar.gz";
    sha256 = "0zsjn9jg7ghll28bj4hb0ka8shjvm8h2q03ad9pb6hwnli8mkcsd";
  };

  installPhase = ''
    mkdir -p "$out/doc"
    for F in COPYING README AUTHORS INSTALL
    do
      cp "$F" "$out/doc/"
    done

    mkdir -p "$out/bin"
    cp lppf "$out/bin"
    chmod +x "$out/bin"/*
  '';
}
