{ fetchFromGitHub, hasBinary, haskellNewBuild, withDeps }:

with rec {
  src = fetchFromGitHub {
    owner  = "lspitzner";
    repo   = "brittany";
    rev    = "21ef8b2";
    sha256 = "0xcf6rp90m34y72fijblcmsdwwwl3g6jbw1g4yc3r5cb8rpks82p";
  };

  brittany = haskellNewBuild { dir = src; name = "brittany"; };

  check = hasBinary brittany "brittany";
};

withDeps [ check ] brittany
