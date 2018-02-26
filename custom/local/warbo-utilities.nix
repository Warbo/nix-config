{ pkgHasBinary, nixpkgs1709, repo, repoSource, runCommand, self,
  withLatestGit }:

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
      rev    = "48c6d57";
      sha256 = "19796lkq00x39pbmykvik2g7aixql08znkgrav92bq2yw7j3nxm3";
    };
  };
};

pkgHasBinary "jo" pkg
