{ stdenv, git2html-real, onOff }:

stdenv.lib.overrideDerivation git2html-real (old: {
  src = latestGit {
    url = onOff http://chriswarbo.net/git/git2html.git
                /home/chris/Programming/git2html;
  };
})
