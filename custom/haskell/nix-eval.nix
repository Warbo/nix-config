self: super: with self;

haskellGit {
  url    = "${repoSource}/nix-eval.git";
  stable = {
    rev    = "06e23e7";
    sha256 = "0m8lykjdkr5v0zzn2qllp5jxd2qirj4g8z1sk3z0wfqakv478hly";
  };
}
