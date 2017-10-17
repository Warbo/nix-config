{ repoSource, self, withLatestGit }:

withLatestGit {
  url      = "${repoSource}/warbo-utilities.git";
  srcToPkg = src: import "${src}" { nixPkgs = self; };
  stable   = {
    rev    = "33ba16d45b5a5cd32914eefd997d37bd104db476";
    sha256 = "1ics5i17hrpg5kmphn9ksmr9hw02lymjarmkm6wijhv5incnhrcq";
  };
}
