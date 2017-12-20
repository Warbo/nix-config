{ repoSource, self, withLatestGit }:

withLatestGit {
  url      = "${repoSource}/warbo-utilities.git";
  srcToPkg = src: import "${src}" { nixPkgs = self; };
  stable   = {
    rev    = "c7b6e4b";
    sha256 = "1nw0i5nsdhx3zpi2djqsvb9aixiyinn01sxq32047n4p44zv5s0w";
  };
}
