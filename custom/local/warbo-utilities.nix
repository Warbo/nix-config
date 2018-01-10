{ repoSource, self, withLatestGit }:

withLatestGit {
  url      = "${repoSource}/warbo-utilities.git";
  srcToPkg = src: import "${src}" { nixPkgs = self; };
  stable   = {
    rev    = "457be3b";
    sha256 = "19pyzhy76v7z8y0i51hhpdnz4667x4kb0yvys87sps0yd3359h5g";
  };
}
