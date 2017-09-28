{ repoSource, self, withLatestGit }:

withLatestGit {
  url      = "${repoSource}/warbo-utilities.git";
  srcToPkg = src: import "${src}" { nixPkgs = self; };
}
