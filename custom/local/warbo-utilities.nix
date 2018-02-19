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
      rev    = "bb2dd9c";
      sha256 = "1z0qqx0ar5aviwwvbjry7sv2jqb86qspd0cjnv25khkmjnng1jqz";
    };
  };
};

pkgHasBinary "jo" pkg
