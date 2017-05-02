{ git2html-real, latestGit, onOff, stdenv }:

stdenv.lib.overrideDerivation git2html-real (old: {
  src = latestGit {
    url = "${repoSource}/git2html";
  };
})
