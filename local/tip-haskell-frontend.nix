{cabal, fetchgit, haskellPackages, tipLib, geniplate}:

cabal.mkDerivation (self : {
  pname = "tip-haskell-frontend";
  version = "20150323";

  src = fetchgit {
    url = "https://github.com/tip-org/tools.git";
    rev = "30c7c93";
    sha256 = "17gak4s2j2c8v546p4m97aadg26jk1r84zhw6mz105638nxs7q0c";
  };

  # Repo contains 2 cabal projects; discard tip-lib
  postUnpack = ''
    for dir in tools-*; do
      mv "$dir/tip-haskell-frontend" "./tip-haskell-frontend"
      rm -rf "$dir"
      mv "tip-haskell-frontend" "$dir"
    done
  '';

  propagatedBuildInputs = [
    geniplate
    tipLib
    haskellPackages.QuickCheck
    haskellPackages.ghcPaths
    haskellPackages.mtl
    haskellPackages.prettyShow
    haskellPackages.split
  ];
})
