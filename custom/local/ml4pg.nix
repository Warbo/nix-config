{ latestGit, localOnly, repoSource }:

import (latestGit {
          url = "${repoSource}/ml4pg.git";
          ref = "master";
        })
