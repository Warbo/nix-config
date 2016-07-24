{ callPackage, latestGit, onOff }:

callPackage (latestGit {
  url = onOff http://chriswarbo.net/git/run-weka.git
              "/home/chris/Programming/repos/run-weka.git";
}) {}
