self: super:

with self;
haskellGit {
  url    = "${repoSource}/ghc-dup.git";
  stable = {
    rev    = "f30658f";
    sha256 = "06jfb7ywny0lm7f1frcysnwf39ba675wqbnfjzmgd7iv1pc2rk7l";
  };
}
