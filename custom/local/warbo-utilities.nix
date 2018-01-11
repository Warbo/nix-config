{ repoSource, self, withLatestGit }:

withLatestGit {
  url      = "${repoSource}/warbo-utilities.git";
  srcToPkg = src: import "${src}" { nixPkgs = self; };
  stable   = {
    rev    = "90ec278";
    sha256 = "0nvgp4ajrlxy6x1pw2kkqvimj4qpykww6b9p126gycmp7zaylv2w";
  };
}
