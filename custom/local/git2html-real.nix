{ stdenv, latestGit }:

stdenv.mkDerivation {
  name = "git2html";

  src = latestGit { url = https://github.com/Hypercubed/git2html.git; };

  installPhase = ''
    mkdir -p "$out/bin"
    cp git2html.sh "$out/bin/git2html"
  '';
}
