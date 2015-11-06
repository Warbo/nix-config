{ stdenv, coq, latestGit }:

stdenv.lib.overrideDerivation coq (oldAttrs : {
  name  = "coq-mtac";
  src   = latestGit {
    url = https://github.com/beta-ziliani/coq.git;
    ref = "SafeRefs-1.2";
  };
})
