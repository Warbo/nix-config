{ repoSource, self, stable, withLatestGit }:

withLatestGit {
  url      = "${repoSource}/warbo-utilities.git";
  srcToPkg = src: import "${src}" (if stable
                                      then {}
                                      else { nixPkgs = self; });
  stable   = {
    rev    = "32fb6c5";
    sha256 = "1pnf9isglp17racrglww2lv59dvibbrrcbzrgp8v27zs57qj8naf";
  };
}
