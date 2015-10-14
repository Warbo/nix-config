{ stdenv, fetchurl, jre, which }:

let scholarFix = fetchurl {
      url = http://downloads.docear.org/docear-metadata-lib-0.0.1.jar;
      sha256 = "1xwa16g7ba56srabi0wvw8xah4ivr3znp9rrygc4j830333xj2s3";
    };
in stdenv.mkDerivation {
  name = "docear";

  src = fetchurl {
    url    = http://docear.org/download/docear_linux.tar.gz;
    sha256 = "0ks8vinxj4r9az5cjjhxgn81alyafc60baram4lfpxqpkz83p476";
  };

  propagatedBuildInputs = [ which jre ];

  installPhase = ''
    mkdir -p "$out/lib"
    cp -r . "$out/lib/docear"

    rm "$out/lib/docear/plugins/org.docear.plugin.bibtex/lib/docear-metadata-lib-0.0.1.jar"
    cp "${scholarFix}" "$out/lib/docear/plugins/org.docear.plugin.bibtex/"

    mkdir -p "$out/bin"
    ln -s "$out/lib/docear/docear.sh" "$out/bin/docear"
  '';
}
