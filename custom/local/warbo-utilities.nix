{ repoSource, self, withLatestGit }:

withLatestGit {
  url      = "${repoSource}/warbo-utilities.git";
  srcToPkg = src: import "${src}" { nixPkgs = self; };
  stable   = {
    rev    = "a4c5a04";
    sha256 = "1jg0zmda00afz49vqpykpc2f1wpsp06shacsgi5yisyrji56vvw6";
  };
}
