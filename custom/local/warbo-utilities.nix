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
      rev    = "231fe70";
      sha256 = "0lr0nzm3hs5f46fsvgv0gxl1ip4q0ss3vz0giplf4pn0fa5af4fm";
    };
  };
};

pkgHasBinary "jo" pkg
