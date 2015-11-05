{ stdenv, fetchgit }:

stdenv.mkDerivation {
  name = "git2html";

  src = fetchgit {
    url = http://hssl.cs.jhu.edu/~neal/git2html.git;
    rev = "b29cc9517980058cce3f550c4befcf73ee8147bc";
    sha256 = "1a7xrk2pvw450s45sw5dwap7a5qfalpr7jddc0h8gma540r43pnb";
  };

  installPhase = ''
    mkdir -p "$out/bin"
    cp git2html.sh "$out/bin/git2html"
  '';
}
