self: super: with self;
runCabal2nix {
  url = latestGit {
    url = "http://chriswarbo.net/git/tinc.git";
  };
}
