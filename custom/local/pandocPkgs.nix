# Fixed versions of pandoc, panpipe, panhandle, pandoc-citeproc and dependencies
{ haskell, haskellPkgsDeps, latestGit, lib, repoSource }:

with lib;
with {
  hSet = haskellPkgsDeps {
    deps = [
      "base >= 4.8"
      "pandoc-citeproc == 0.10.4"
      "panpipe == 0.2.0.0"
      "panhandle == 0.3.0.0"
      "aeson == 0.11.3.0"
      "attoparsec == 0.13.1.0"
      "tasty == 0.11.2.1"
      "lazysmallcheck2012"
      "pandoc"
    ];
    hsPkgs = haskell.packages.ghc7103;
    extra-sources = [
      haskell.packages.ghc7103.lazysmallcheck2012.src
      (latestGit {
        url    = "${repoSource}/panhandle.git";
        stable = {
          rev    = "7e44d75";
          sha256 = "1cgk5wslbr507fmh1fyggvk15lipa8x815392j9qf4f922iifdzn";
        };
      })
    ];
  };
};

hSet.ghcWithPackages (h: [ h.pandoc h.panpipe h.pandoc-citeproc h.panhandle ])
