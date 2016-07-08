{ git2html-real, latestGit, onOff, stdenv }:

stdenv.lib.overrideDerivation git2html-real (old: {
  src = latestGit {
    url = onOff http://chriswarbo.net/git/git2html.git
                /home/chris/Programming/git2html;
  };
})
