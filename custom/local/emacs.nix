{ emacs25 ? null, emacsPackagesNgGen, super }:

with rec {
  version = if emacs25 == null
               then super.emacs
               else emacs25;
};
(emacsPackagesNgGen version).emacsWithPackages (epkgs:
  (with epkgs.elpaPackages;  []) ++
  (with epkgs.melpaPackages; []))
