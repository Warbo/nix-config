{ stdenv, fetchurl, pkgconfig, freetype, glib, glew, libmpeg2, SDL2, openal, libXi, gettext, zip }:

let name    = "fs-uae";
    version = "2.6.2";
in stdenv.mkDerivation {
  inherit name version;
  src = fetchurl {
    url = "http://fs-uae.net/fs-uae/stable/${version}/fs-uae-${version}.tar.gz";
    sha256 = "1m0d7jx9slnkdzgzbc76vw2cxh43idlk0s74bk78a7fkl26qwcii";
  };
  buildInputs = [ pkgconfig freetype glib glew libmpeg2 SDL2 openal libXi gettext zip ];
}
