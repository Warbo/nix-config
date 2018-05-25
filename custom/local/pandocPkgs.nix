# Fixed versions of pandoc, panpipe, panhandle, pandoc-citeproc and dependencies
{ hasBinary, haskell, haskellPkgsDeps, latestGit, lib, repoSource, runCommand,
  withDeps }:

with lib;
with haskellPkgsDeps {
  deps = [
    "base >= 4.8"
    "pandoc-citeproc == 0.10.4"
    "panpipe == 0.2.0.0"
    "panhandle == 0.3.0.0"
    #"aeson == 0.11.3.0"
    "attoparsec == 0.13.0.2"
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
with rec {
  # Add the "gcRoots" as dependencies; these are derivations we imported in order
  # order to generate the required Haskell packages, but which aren't actually
  # included in the dependencies of anything. Notably this includes hackageDb.
  # By adding these as dependencies here, we ensure the GC sees them as live.
  pkg = withDeps gcRoots (runCommand "pandocPkgs"
    {
      wanted = hsPkgs.ghcWithPackages (h: [
        h.pandoc
        h.panpipe
        h.pandoc-citeproc
        h.panhandle
      ]);
    }
    ''
      # Pluck out the binaries we want, ignore those we don't (e.g. ghc)
      mkdir -p "$out/bin"
      for P in pandoc pandoc-citeproc panhandle panpipe
      do
        ln -s "$wanted/bin/$P" "$out/bin/$P"
      done
    '');

  tested = withDeps [ (hasBinary pkg "pandoc") ] pkg;
};
{
  pkg   = tested;
  tests = tested;
}
