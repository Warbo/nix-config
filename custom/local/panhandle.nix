{ haskellPackages, tincify }:

tincify (haskellPackages.panhandle // {
  extras = [/*{ inherit (haskellPackages) */"lazysmallcheck2012"]/*; }*/;
})
