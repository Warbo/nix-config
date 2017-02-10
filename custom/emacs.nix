self: super:

{
  emacs = (self.emacsPackagesNgGen self.emacs25).emacsWithPackages (epkgs:
    (with epkgs.elpaPackages; [ /*auctex company*/ ]) ++
    (with epkgs.melpaPackages; [ intero ])
  );
}
