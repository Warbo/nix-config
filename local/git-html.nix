# Render a git repo to HTML
with import <nixpkgs> {};

{ src, url? "http://chriswarbo.net/git/", name }:

stdenv.mkDerivation {
  name = "git-html-${name}";

  src = src;

  buildInputs = [ git git2html ];

  buildPhase = ''
    cd ..
    mkdir "html"
    ungit=$(basename  .git) # Remove any ".git" suffix
    git2html -p "${name}" \
             -r "git-repo-${name}"  \
             -l "${url}${name}.git" \
             "html"
  '';

  installPhase = ''
    mkdir -p "$out"
    shopt -s dotglob
    cp -ar html/* "$out/" # -a preserves hard links
    shopt -u dotglob
  '';

  fixupPhase = "";  # Don't fiddle with the repo contents
}
