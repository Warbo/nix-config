import ../imports/haskellGit.nix {
  url = if import ../imports/localOnly.nix
           then "/home/chris/Programming/repos/order-deps.git"
           else http://chriswarbo.net/git/order-deps.git;
}
