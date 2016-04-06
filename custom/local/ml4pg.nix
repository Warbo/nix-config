{ latestGit }:

import (latestGit {
          url = if (import <nixpkgs> {}).localOnly
                   then http://chriswarbo.net/git/ml4pg.git
                   else /home/chris/Programming/repos/ml4pg.git;
          ref = "master";
        })
