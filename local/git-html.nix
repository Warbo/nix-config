{ repos }:

with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "git-html";

  src = repos;

  buildInputs = [ git git2html ];

  buildPhase = ''
    echo "$PATH"
    mkdir html
    for repo in *.git
    do
      ungit=$(basename "$repo" .git)
      mkdir -p "html/$ungit"
      git2html -p "$ungit" \
               -r "$repo"  \
               -l "http://chriswarbo.net/git/$repo" \
               "html/$ungit"
    done
  '';

  installPhase = ''
    mkdir -p "$out"
    cp -ar html/* "$out/"
  '';
}
