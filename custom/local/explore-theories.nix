{ pkgs, withLatestGit }:

withLatestGit {
  url      =  if (import <nixpkgs> {}).localOnly
                 then /home/chris/Programming/repos/explore-theories.git
                 else http://chriswarbo.net/git/explore-theories.git;
  srcToPkg = (x: pkgs.callPackage "${x}" {});
}
