self: super: with self;

haskellGit {
  url    = "${repoSource}/mlspec.git";
  stable = {
    rev    = "8f97e7f";
    sha256 = "1ay4zw55k659cdpg1mbb3jcdblabyajpj657v4fc6wvydqvia6d5";
  };
}
