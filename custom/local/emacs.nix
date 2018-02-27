{ emacs25 ? null, emacsPackagesNgGen, super }:

with rec {
  version = if emacs25 == null
               then super.emacs
               else emacs25;

  # GTK crashes if X restarts, plus GTK3 is horrible and it's slow
  lucid = version.override { withGTK2 = false; withGTK3 = false; };
};
(emacsPackagesNgGen lucid).emacsWithPackages (epkgs:
  (with epkgs.elpaPackages;  []) ++
  (with epkgs.melpaPackages; []))
