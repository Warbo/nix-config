self: super: with self;

haskellGit {
  url    = "${repoSource}/mlspec.git";
  stable = {
    rev    = "e7946e0";
    sha256 = "10knpsbdk3rvcdq1wircjq2pz0x66fd5h2hzmxnsw95awyviaq21";
  };
}
