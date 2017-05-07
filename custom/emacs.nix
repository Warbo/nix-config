self: super:

with rec {
  version = self.emacs25 or super.emacs;
};
{
  emacs = (self.emacsPackagesNgGen version).emacsWithPackages (epkgs:
    (with epkgs.elpaPackages;  []) ++
    (with epkgs.melpaPackages; [])
  );
}
