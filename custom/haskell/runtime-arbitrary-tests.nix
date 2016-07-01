import ../imports/haskellGit.nix {
  url = if import ../imports/localOnly.nix
        then "/home/chris/Programming/repos/runtime-arbitrary-tests.git"
        else http://chriswarbo.net/git/runtime-arbitrary-tests.git;
}
