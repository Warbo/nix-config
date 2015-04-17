{cabal, fetchgit, haskellPackages, geniplate ? haskellPackages.geniplate}:

cabal.mkDerivation (self : {
  pname = "tip-lib";
  version = "20150323";

  src = fetchgit {
    url = "https://github.com/tip-org/tools.git";
    rev = "30c7c93";
    sha256 = "17gak4s2j2c8v546p4m97aadg26jk1r84zhw6mz105638nxs7q0c";
  };

  # Repo contains 2 cabale projects; discard tip-haskell-frontend
  postUnpack = ''
    for dir in tools-*; do
      mv "$dir/tip-lib" "./tip-lib"
      rm -rf "$dir"
      mv "tip-lib" "$dir"
    done
  '';

  propagatedBuildInputs = [ geniplate ];
})
