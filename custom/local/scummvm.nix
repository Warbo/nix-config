{ stdenv, fetchurl, SDL, libogg, libjpeg, libmpeg2, libvorbis, flac, libmad, libpng, libtheora, fluidsynth, freetype, zlib, git, nasm }:

stdenv.mkDerivation {
  name = "scummvm";
  src  = fetchurl {
    url    = "http://downloads.sourceforge.net/project/scummvm/scummvm/1.7.0/scummvm-1.7.0.tar.bz2";
    sha256 = "0rifghir3xgyya5l5zgcvm3pv8cjyvz2hva5smka9bqiz660xzyr";
  };
  buildInputs = [ SDL ];
}
