{ repoSource, self, stable, withLatestGit }:

withLatestGit {
  url      = "${repoSource}/warbo-utilities.git";
  srcToPkg = src: import "${src}" (if stable
                                      then {}
                                      else { nixPkgs = self; });
  stable   = {
    rev    = "30f07ff";
    sha256 = "04wczkd893fk8cappp9xc1hj0nn3c0p1q4jjk4asyld7ivx0qri5";
  };
}
