{ callPackage, hasBinary, repo1609, withDeps }:

with rec {
  pkg = callPackage "${repo1609}/pkgs/applications/networking/browsers/conkeror"
                    {};

  tested = withDeps [ (hasBinary pkg "conkeror") ] pkg;
};
{
  pkg   =   tested;
  tests = [ tested ];
}
