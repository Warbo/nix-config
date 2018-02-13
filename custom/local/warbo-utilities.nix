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
      rev    = "004f327";
      sha256 = "1dhyhr6vph84x35wckibnfmlmbz6fwb2lb3m9hs367al0lzgxbpz";
    };
  };
};

pkgHasBinary "jo" pkg
