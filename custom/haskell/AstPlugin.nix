self: super: with self;

haskellGit {
  url    = "${repoSource}/ast-plugin.git";
  stable = {
    rev    = "a04f6fe";
    sha256 = "1gmkv4l38vpvhg2h8dwv4gf8dq1d0lr0zxd5j9szi90xb8nl2241";
  };
}
