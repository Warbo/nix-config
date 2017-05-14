{ haskellPackages, isoTincify }:

isoTincify (haskellPackages.panhandle // {
  extras = [ "lazysmallcheck2012" ];
})
