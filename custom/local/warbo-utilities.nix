{ pkgHasBinary, repoSource, self, withLatestGit, forceLatest ? false }:

with {
  pkg = withLatestGit {
    url      = "${repoSource}/warbo-utilities.git";
    srcToPkg = src: import "${src}" { nixPkgs = self; };
    stable   = {
      rev        = "e806837";
      sha256     = "05g1kqaqymnnnfxx516jilz5a9salhv5ggcppfi0bbmmd7i1jy8g";
      unsafeSkip = forceLatest;
    };
  };
};

pkgHasBinary "jo" pkg
