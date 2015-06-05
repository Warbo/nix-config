# Deep clone a git repo
with import <nixpkgs> {};

{ name, repo }:

stdenv.mkDerivation {
  name = "git-repo-${name}";

  src = with stdenv.lib;
        if types.path.check repo   # Paths should be full git clones
           then repo
        else if isDerivation repo  # Derivations should come from fetchgit
                then overrideDefinition repo (old: {
                  deepClone = true; # We want the whole repo
                })
                else throw "git-repo should be path or result of fetchgit";

  buildInputs = [ git ];

  buildPhase = ''
    mv hooks/post-update.sample hooks/post-update
    chmod +x hooks/post-update
    sh hooks/post-update
  '';

  installPhase = ''
    mkdir -p "$out"
    shopt -s dotglob
    cp -r * "$out/"
    shopt -u dotglob
  '';

  fixupPhase = "";  # Don't fiddle with repo contents
}
