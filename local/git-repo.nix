# Render a git repository to a static HTML site
with import <nixpkgs> {};

{ src, url? "http://chriswarbo.net/git/", repo, suffix? "" }:

stdenv.mkDerivation {
  name = "git-html-${repo}";

  src = with stdenv.lib;
        if types.path.check src   # Paths should be full git clones
           then "${src}/${repo}${suffix}"
        else if isDerivation src  # Derivations should come from fetchgit
                then overrideDefinition src (old: {
                  deepClone = true; # We want the whole repo
                })
                else throw "git-html src should be path or result of fetchgit";

  buildInputs = [ git git2html ];

  buildPhase = ''
    mv *
    ls -lh
    #mkdir "html"
    #ungit=$(basename "${repo}" .git) # Remove any ".git" suffix
    #mkdir -p "html"
    #git2html -p "$ungit" \
    #         -r "${repo}"  \
    #         -l "${url}${repo}" \
    #         "html/$ungit"
  '';

  installPhase = ''
    mkdir -p "$out"
    #cp -ar html/* "$out/"
  '';
}
