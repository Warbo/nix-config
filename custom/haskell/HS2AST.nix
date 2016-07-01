import ../imports/haskellGit.nix {
  url = if import ../imports/localOnly.nix
           then "/home/chris/Programming/repos/hs2ast.git"
           else http://chriswarbo.net/git/hs2ast.git;
}
