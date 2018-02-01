{ repoSource, self, stable, withLatestGit }:

withLatestGit {
  url      = "${repoSource}/warbo-utilities.git";
  srcToPkg = src: import "${src}" (if stable
                                      then {}
                                      else { nixPkgs = self; });
  stable   = {
    rev    = "94c8568";
    sha256 = "1gi87zn5sr6jggds37nwnazvm38mnvglhn1qzc16pkb0zk18nd5b";
  };
}
