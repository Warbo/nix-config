{ localOnly, withLatestGit }:

withLatestGit {
  url      =  if import ../imports/localOnly.nix
                 then "/home/chris/Programming/repos/warbo-utilities.git"
                 else http://chriswarbo.net/git/warbo-utilities.git;
  srcToPkg = (x: import "${x}");
}
