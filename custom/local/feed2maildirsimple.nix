{ latestGit, repoSource, pkgs }:

with rec {
  src = latestGit {
    url    = "${repoSource}/feed2maildir.git";
    stable = {
      rev    = "6c19186";
      sha256 = "0062flvnfpkhihx6shn62n35b899aldwxivrc0bg0rm5128wxhpl";
    };
  };
};

import "${src}" { inherit pkgs; }
