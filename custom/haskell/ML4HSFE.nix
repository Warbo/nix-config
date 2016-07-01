import ../imports/haskellGit.nix {
  url = if import ../imports/localOnly.nix
           then "/home/chris/Programming/repos/ml4hsfe.git"
           else http://chriswarbo.net/git/ml4hsfe.git;
}
