import ../imports/haskellGit.nix {
  url = if import ../imports/localOnly.nix
           then "/home/chris/Programming/repos/arbitrary-haskell.git"
           else http://chriswarbo.net/git/arbitrary-haskell.git;
}
