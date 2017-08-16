{ emacs25 ? null, emacsPackagesNgGen, origPkgs }:

with rec {
  version = if emacs25 == null
               then origPkgs.emacs
               else emacs25;
};
(emacsPackagesNgGen version).emacsWithPackages (epkgs:
  (with epkgs.elpaPackages;  []) ++
  (with epkgs.melpaPackages; []))
