# Fixed versions of pandoc, panpipe, panhandle, pandoc-citeproc and dependencies

{ attrsToDirs, fetchgit, lib, mkStableHackageDb, nixpkgs1609, runCabal2nix,
  repoSource, wrap }:

with lib;
with rec {
  hackage = mkStableHackageDb {
    rev    = "c008e28";
    sha256 = "0kfcc7dw6sahgkv130r144pfjsxwzq8h479fw866nf875frvpblz";
  };

  # runCabal2nix with a fixed Hackage revision
  c2n = url: runCabal2nix {
    inherit url;
    packageDb = hackage.installed;
  };

  # Fetches a package with the given name and version from Hackage
  go = self: name: ver: self.callPackage (c2n "cabal://${name}-${ver}") {};

  # Packages which aren't on Hackage
  extra = self: {
    lazysmallcheck2012 =
      assert !(hasAttr "lazysmallcheck2012" hackage.versions) ||
             abort "Hackage has lazysmallcheck2012, use it";
      self.callPackage (c2n (fetchgit {
        url    = repoSource + "/lazy-smallcheck-2012.git";
        rev    = "dbd6fba10a24b2e46d6250d2735be2d792ff69bb";
        sha256 = "1i3by7mp7wqy9anzphpxfw30rmbsk73sb2vg02nf1mfpjd303jj7";
      })) {};

    # Writer tests fail due to read-only filesystem
    pandoc = nixpkgs1609.haskell.lib.dontCheck
      (self.callPackage (c2n "cabal://pandoc-1.17.2") {});

    # We need a fix from 0.3, but our hackage index only has 0.2
    panhandle =
      assert !(elem "0.3.0.0" hackage.versions.panhandle) ||
             abort "Hackage has panhandle-0.3, use it";
      self.callPackage (c2n (fetchgit {
        url    = repoSource + "/panhandle.git";
        rev    = "7e44d75";
        sha256 = "1cgk5wslbr507fmh1fyggvk15lipa8x815392j9qf4f922iifdzn";
      })) {};
  };

  # A Haskell package set with particular versions chosen to work for pan*
  pkgs = nixpkgs1609.haskell.packages.ghc7103.override {
    overrides = self: super: extra self // mapAttrs (go self) {
      pandoc-citeproc = "0.10.4";
      panpipe         = "0.2.0.0";

      # Ensures working dependency versions
      aeson      = "0.11.3.0";
      attoparsec = "0.13.1.0";
      tasty      = "0.11.2.1";
    };
  };
};

# Expose the binaries of each package we care about
attrsToDirs {
  bin = listToAttrs (map (name: {
    inherit name;
    value = wrap { file = "${getAttr name pkgs}/bin/${name}"; };
  }) [ "pandoc" "pandoc-citeproc" "panhandle" "panpipe" ]);
}
