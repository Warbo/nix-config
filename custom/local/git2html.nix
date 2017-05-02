{ git2html-real, latestGit, repoSource, stdenv }:

stdenv.lib.overrideDerivation git2html-real (old: {
  src = latestGit {
    url = "${repoSource}/git2html.git";
  };
})
