{ latestGit, stdenv }:
stdenv.mkDerivation {
  name = "font-spacemono";
  src  = latestGit {
    url = https://github.com/googlefonts/spacemono.git;
  };
}
