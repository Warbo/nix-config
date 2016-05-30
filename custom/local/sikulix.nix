{ fetchurl, jre, stdenv }:

stdenv.mkDerivation {
  name = "sikulix";
  src = fetchurl {
    url = "https://launchpad.net/sikuli/sikulix/1.1.0/+download/sikulixsetup-1.1.0.jar";
    md5 = "a33616bac6d4f44785b89a02b110a0f8";
  };

  unpackCmd    = ''
    mkdir src
    cp "$curSrc" src/
  '';

  buildPhase   = "";

  installPhase = ''
    find .
  '';

  propagatedBuildInputs = [ jre ];
}
