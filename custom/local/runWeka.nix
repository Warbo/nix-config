let pkgs = import <nixpkgs> {};
 in import (pkgs.latestGit {
      url = if pkgs.localOnly
               then "/home/chris/Programming/repos/run-weka.git"
               else http://chriswarbo.net/git/run-weka.git;
    })
