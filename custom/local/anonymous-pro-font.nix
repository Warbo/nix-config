{ fetchurl, runCommand, unzip, utillinux }:

runCommand "anonymous-pro-font"
  {
    zipped = fetchurl {
      url    = "http://www.marksimonson.com/assets/content/fonts/AnonymousPro-1.002.zip";
      sha256 = "1asj6lykvxh46czbal7ymy2k861zlcdqpz8x3s5bbpqwlm3mhrl6";
    };
    buildInputs = [ unzip utillinux ];
  }
  ''
    D="$out/share/fonts/truetype"
    DOC="$out/share/anonymous-pro"

    mkdir -p "$D"
    mkdir -p "$DOC"

    unzip "$zipped"

    mv AnonymousPro-1.002.001/*.ttf "$D"/
    mv AnonymousPro-1.002.001/*.txt "$DOC"/
  ''
