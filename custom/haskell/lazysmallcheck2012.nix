import ../imports/haskellGit.nix {
  url = if import ../imports/localOnly.nix
           then "/home/chris/Programming/repos/lazy-smallcheck-2012.git"
           else http://chriswarbo.net/git/lazy-smallcheck-2012.git;
}
