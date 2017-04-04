{ git2html-real, latestGit, onOff, stdenv }:

stdenv.lib.overrideDerivation git2html-real (old: {
  src = latestGit {
    url = /home/chris/Programming/git2html;
  };
})
