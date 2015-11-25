{ stdenv, git2html-real }:

stdenv.lib.overrideDerivation git2html-real (old: {
  src = /home/chris/Programming/git2html;
})
