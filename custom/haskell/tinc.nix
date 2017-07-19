self: super: with self;
runCabal2nix {
  url = latestGit {
    url = "${repoSource}/tinc.git";
  };
}
