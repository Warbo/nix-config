{ latestGit, repoSource }:

import (latestGit {
          url    = "${repoSource}/ml4pg.git";
          ref    = "master";
          stable = {
            rev    = "d9392e0";
            sha256 = "11sslpidw77747k6qba0acvifxd0wg89nzqbbkpdxajmfb3m776v";
          };
        })
