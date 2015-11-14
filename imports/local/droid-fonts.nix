{stdenv, fetchurl, xz, gnutar, utillinux }:

stdenv.mkDerivation {
  name = "droid-fonts";
  zipped = fetchurl {
             url    = "http://http.debian.net/debian/pool/main/f/fonts-android/fonts-android_4.4.4r2.orig.tar.xz";
             sha256 = "0w7idnjwckyqypxm5ccqj9wg15zjq1z92a98vfvnbyljn95bd9ir";
           };
  buildInputs = [ xz gnutar utillinux ];
  buildCommand = ''
    source $stdenv/setup

    D="$out/share/fonts/droid"
    echo "Making font dir '$D'"
    mkdir -p "$D"
    cd "$D"

    echo "Unzipping '$zipped'"
    xzcat "$zipped" | tar x

    echo "Cleaning up non-fonts"
    shopt -s nullglob
    rm *.mk
    rm *.xml
  '';
}
