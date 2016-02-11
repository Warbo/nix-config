{ pkgs, withLatestGit }:

withLatestGit {
  url      = http://chriswarbo.net/git/explore-theories.git;
  srcToPkg = (x: pkgs.callPackage "${x}" {});
}
