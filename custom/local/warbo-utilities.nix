{ repoSource, self, stable, withLatestGit }:

withLatestGit {
  url      = "${repoSource}/warbo-utilities.git";
  srcToPkg = src: import "${src}" (if stable
                                      then {}
                                      else { nixPkgs = self; });
  stable   = {
    rev    = "bf69378";
    sha256 = "1a1ss17cvc94xg83vjgwbqc6aphx2xy3hapn2j1lk464l2iwd1bn";
  };
}
