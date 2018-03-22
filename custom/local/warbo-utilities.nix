{ pkgHasBinary, nixpkgs1709, repo, repoSource, runCommand, self,
  withLatestGit, forceLatest ? false }:

with rec {
  version = import (runCommand "nixpkgs-version.nix" { inherit repo; } ''
    V=$(cat "$repo/.version")
    echo "\"$V\"" > "$out"
  '');

  nixPkgs = self // (if version == "17.09"
                        then {}
                        else { inherit (nixpkgs1709) ipfs; });

  pkg = withLatestGit {
    url      = "${repoSource}/warbo-utilities.git";
    srcToPkg = src: import "${src}" { inherit nixPkgs; };
    stable   = {
      rev        = "e806837";
      sha256     = "05g1kqaqymnnnfxx516jilz5a9salhv5ggcppfi0bbmmd7i1jy8g";
      unsafeSkip = forceLatest;
    };
  };
};

pkgHasBinary "jo" pkg
