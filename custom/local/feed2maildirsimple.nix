{ latestGit, repoSource, pkgs }:

with rec {
  src = latestGit {
    url    = "${repoSource}/feed2maildir.git";
    stable = {
      rev    = "706a855";
      sha256 = "1phf27vdyvv214x085828rwhd9yfzfna0v510xymzq6z6kd06xl1";
    };
  };
};

import "${src}" { inherit pkgs; }
