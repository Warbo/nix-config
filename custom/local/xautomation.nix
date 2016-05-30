{ fetchurl, stdenv, xorg, libXtst, libXi, libpng }:

stdenv.mkDerivation {
  name = "xautomation";
  src  = fetchurl {
    url    = "http://www.hoopajoo.net/static/projects/xautomation-1.09.tar.gz";
    sha256 = "03azv5wpg65h40ip2kk1kdh58vix4vy1r9bihgsq59jx2rhjr3zf";
  };

  buildInputs = [ xorg.libX11 libXtst xorg.xextproto xorg.xinput libXi libpng ];
}
