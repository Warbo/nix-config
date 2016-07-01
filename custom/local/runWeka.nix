import (import ../imports/latestGit.nix {
  url = if import ../imports/localOnly.nix
           then "/home/chris/Programming/repos/run-weka.git"
           else http://chriswarbo.net/git/run-weka.git;
})
