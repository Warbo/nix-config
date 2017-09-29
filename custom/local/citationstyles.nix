{ stdenv, latestGit }:

stdenv.mkDerivation rec {
  name = "citation-styles";
  src = latestGit {
    url    = https://github.com/citation-style-language/styles.git;
    stable = {
      rev    = "fcb341a";
      sha256 = "1yc0b03g962cgg2paci5z99gws55qv5lk23fgjc80if1gl4falpv";
    };
  };

  installPhase = ''
    mkdir -p "$out/lib/styles"
    cp *.csl "$out/lib/styles/"
  '';
}
