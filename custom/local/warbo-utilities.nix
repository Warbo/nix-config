{ repoSource, self, withLatestGit }:

withLatestGit {
  url      = "${repoSource}/warbo-utilities.git";
  srcToPkg = src: import "${src}" { nixPkgs = self; };
  stable   = {
    rev    = "6235473";
    sha256 = "0k1wrr9mw6zhl6mfmkplwxp5kgkq7g46hrwyf10v4d2p9l736868";
  };
}
