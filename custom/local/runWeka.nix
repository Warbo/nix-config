self: super: with self;

import (latestGit {
  url = onOff http://chriswarbo.net/git/run-weka.git
              "/home/chris/Programming/repos/run-weka.git";
})
