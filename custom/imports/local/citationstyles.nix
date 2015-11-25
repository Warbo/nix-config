{ stdenv, latestGit }:

stdenv.mkDerivation rec {
  name = "citation-styles";
  src = latestGit { url = https://github.com/citation-style-language/styles.git; };

  installPhase = ''
    mkdir -p "$out/lib/styles"
    cp *.csl "$out/lib/styles/"
  '';
}
