# Fixed versions of pandoc, panpipe, panhandle, pandoc-citeproc and dependencies
{ haskell, haskellPkgsDeps, latestGit, lib, repoSource, runCommand }:

with lib;
with rec {
  hSet = haskellPkgsDeps {
    deps = [
      "base >= 4.8"
      "pandoc-citeproc == 0.10.4"
      "panpipe == 0.2.0.0"
      "panhandle == 0.3.0.0"
      "aeson == 0.11.3.0"
      "attoparsec == 0.13.0.2" #"attoparsec == 0.13.1.0" seems to have undeclared deps on fail and semigroups
      /*"fail == 4.9.0.0"
      "semigroups == 0.18.3"*/
      "tasty == 0.11.2.1"
      "lazysmallcheck2012"
      "pandoc"
    ];

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

    hsPkgs = haskell.packages.ghc7103;

    useOldZlib = true;
  };

  wanted = hSet.ghcWithPackages (h: [
    h.pandoc
    h.panpipe
    h.pandoc-citeproc
    h.panhandle
  ]);
};

runCommand "pandocPkgs" { inherit wanted; } ''
  # Pluck out the binaries we want, ignore those we don't (e.g. ghc)
  mkdir -p "$out/bin"
  for P in pandoc pandoc-citeproc panhandle panpipe
  do
    ln -s "$wanted/bin/$P" "$out/bin/$P"
  done
''
