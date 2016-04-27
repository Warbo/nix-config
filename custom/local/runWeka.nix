{ latestGit }:

import (latestGit {
          url = if (import <nixpkgs> {}).localOnly
                   then "/home/chris/Programming/repos/run-weka.git"
                   else http://chriswarbo.net/git/run-weka.git;
        })
