{ latestGit, localOnly }:

import (latestGit {
          url = if localOnly
                   then "/home/chris/Programming/repos/ml4pg.git"
                   else http://chriswarbo.net/git/ml4pg.git;
          ref = "master";
        })
