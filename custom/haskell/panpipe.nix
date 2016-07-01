import ../imports/haskellGit.nix {
  url = if import ../imports/localOnly.nix
           then "/home/chris/Programming/repos/panpipe.git"
           else http://chriswarbo.net/git/panpipe.git;
}
