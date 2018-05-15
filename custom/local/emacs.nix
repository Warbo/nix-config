{ emacs25 ? null, emacsPackagesNgGen, hasBinary, super, withDeps }:

with rec {
  version = if emacs25 == null
               then super.emacs
               else emacs25;

  # GTK crashes if X restarts, plus GTK3 is horrible and it's slow
  lucid = version.override { withGTK2 = false; withGTK3 = false; };

  pkg = (emacsPackagesNgGen lucid).emacsWithPackages (epkgs:
    with epkgs;
    with elpaPackages;
    with melpaPackages;
    [
      agda2-mode
    ]);

  tested = withDeps [ (hasBinary pkg "emacs") ] pkg;
};
{
  pkg   =   tested;
  tests = [ tested ];
}
