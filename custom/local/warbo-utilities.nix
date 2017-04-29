{ callPackage, repoSource, withLatestGit }:

withLatestGit {
  url      = "${repoSource}/warbo-utilities.git";
  srcToPkg = x: callPackage "${x}" {};
}
