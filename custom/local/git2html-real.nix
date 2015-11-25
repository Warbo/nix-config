{ stdenv, latestGit }:

stdenv.mkDerivation {
  name = "git2html";

  src = latestGit { url = http://hssl.cs.jhu.edu/~neal/git2html.git; };

  installPhase = ''
    mkdir -p "$out/bin"
    cp git2html.sh "$out/bin/git2html"
  '';
}
