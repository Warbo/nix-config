self: super: with self;
runCabal2nix {
  url = latestGit {
    url    = "${repoSource}/tinc.git";
    stable = {
      rev    = "131ab01";
      sha256 = "12ikdb1h52kwd63qzd193h7ky5kwdab4kaxkvcr3q8xfccckr9cf";
    };
  };
}
