{haskellPackages, fetchgit}:

haskellPackages.callPackage (fetchgit {
  name   = "panhandle";
  url    = http://chriswarbo.net/git/panhandle.git;
  rev    = "f49f798";
  sha256 = "0gdaw7q9ciszh750nd7ps5wvk2bb265iaxs315lfl4rsnbvggwkd";
}) {}
