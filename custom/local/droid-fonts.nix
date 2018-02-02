{ fetchurl, gnutar, runCommand, utillinux, xz }:

runCommand "droid-fonts"
  {
    zipped = fetchurl {
      url    = "http://http.debian.net/debian/pool/main/f/fonts-android/fonts-android_4.4.4r2.orig.tar.xz";
      sha256 = "0w7idnjwckyqypxm5ccqj9wg15zjq1z92a98vfvnbyljn95bd9ir";
    };
    buildInputs = [ xz gnutar utillinux ];
  }
  ''
    D="$out/share/fonts/truetype"
    mkdir -p "$D"
    cd "$D"

    echo "Unzipping '$zipped'"
    xzcat "$zipped" | tar x

    echo "Cleaning up non-fonts"
    shopt -s nullglob
    rm *.mk
    rm *.xml
  ''
