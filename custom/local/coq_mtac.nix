{ nixpkgs1609, stdenv, latestGit }:

stdenv.lib.overrideDerivation nixpkgs1609.coq (oldAttrs : {
  name  = "coq-mtac";
  src   = latestGit {
    url = https://github.com/beta-ziliani/coq.git;
    ref = "SafeRefs-1.2";
  };
})
