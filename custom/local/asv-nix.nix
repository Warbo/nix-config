{ callPackage, latestGit, repoSource }:

callPackage (latestGit { url = "${repoSource}/asv-nix.git"; }) {}
