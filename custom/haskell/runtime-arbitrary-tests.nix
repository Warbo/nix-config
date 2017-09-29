self: super: with self;

haskellGit {
  url    = "${repoSource}/runtime-arbitrary-tests.git";
  stable = {
    rev    = "4272695";
    sha256 = "1bcm9f6jcw1svj2r777sah4fyb9vnvcjvjm53mn58453xm64m4iv";
  };
}
