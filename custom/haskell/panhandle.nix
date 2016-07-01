import ../imports/haskellGit.nix {
  url = if ../imports/localOnly.nix
           then "/home/chris/Programming/repos/panhandle.git"
           else http://chriswarbo.net/git/panhandle.git;
}
