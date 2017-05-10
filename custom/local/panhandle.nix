{ haskellPackages, tincify }:

tincify (haskellPackages.panhandle // { extras = [ "lazysmallcheck2012" ]; })
