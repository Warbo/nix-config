{ kde4, kdelibs4, repo1609, self }:

with {
  oldPkg = self.callPackage "${repo1609}/pkgs/applications/office/basket" {
    inherit (kde4) kdepimlibs;
    kdelibs = kdelibs4;
  };
};
if kde4 ? basket
   then kde4.basket
   else oldPkg
