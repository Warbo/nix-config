{ callPackage, latestGit }:

callPackage (latestGit { url = "http://chriswarbo.net/git/asv-nix.git"; }) {}
