import ../imports/haskellGit.nix {
  url = if import ../imports/localOnly.nix
           then "/home/chris/Programming/repos/mlspec.git"
           else http://chriswarbo.net/git/mlspec.git;
}
