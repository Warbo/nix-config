{ latestGit, repoSource, pkgs }:

with rec {
  src = latestGit { url = "${repoSource}/feed2maildir.git"; };
};

import "${src}" { inherit pkgs; }
