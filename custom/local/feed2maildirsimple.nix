{ latestGit, pkgs }:

with rec {
  src = latestGit {
    url = http://chriswarbo.net/git/feed2maildir.git;
  };
};

import "${src}" { inherit pkgs; }
