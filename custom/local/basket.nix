{ kde4, repo1609, self }:

with rec {
  kdelibs = self.kdelibs4 or kde4.kdelibs;

  oldPkg  = self.callPackage "${repo1609}/pkgs/applications/office/basket" {
    inherit kdelibs;
    inherit (kde4) kdepimlibs;
  };
};
if kde4 ? basket
   then kde4.basket
   else oldPkg
