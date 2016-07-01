import ../imports/haskellGit.nix {
  url = if import ../imports/localOnly.nix
           then "/home/chris/Programming/repos/nix-eval.git"
           else http://chriswarbo.net/git/nix-eval.git;
}
