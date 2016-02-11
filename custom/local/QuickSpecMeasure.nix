{ haskellPackages, nixFromCabal }:

haskellPackages.callPackage
  (nixFromCabal "/home/chris/Programming/Haskell/QuickSpecMeasure" null) {}
