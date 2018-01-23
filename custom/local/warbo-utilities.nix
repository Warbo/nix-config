{ repoSource, self, withLatestGit }:

withLatestGit {
  url      = "${repoSource}/warbo-utilities.git";
  srcToPkg = src: import "${src}" { nixPkgs = self; };
  stable   = {
    rev    = "3c13f68";
    sha256 = "19wv9szl6qphlbwjz4ajfybcrjr0y7dwv0qnckavy2q72r94amyn";
  };
}
