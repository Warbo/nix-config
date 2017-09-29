self: super: with self;

haskellGit {
  url    = "${repoSource}/runtime-arbitrary.git";
  stable = {
    rev    = "5b7ff2f";
    sha256 = "11gnfmz48vxvf42xs9255r51vbv1sjghvzi60gcrpx3jk38d2gyb";
  };
}
