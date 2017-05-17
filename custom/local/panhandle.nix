{ haskellPackages, pandoc, tincify }:

tincify (haskellPackages.panhandle // { extras = [ "lazysmallcheck2012" ]; })
        { inherit pandoc; }
