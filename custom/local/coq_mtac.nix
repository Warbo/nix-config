{ coq, latestGit, nixpkgs1609, stable, stdenv }:

with { pkg = if stable then nixpkgs1609.coq else coq; };
stdenv.lib.overrideDerivation pkg (oldAttrs : {
  name  = "coq-mtac";
  src   = latestGit {
    url    = https://github.com/beta-ziliani/coq.git;
    ref    = "SafeRefs-1.2";
    stable = {
      rev    = "2651fd3";
      sha256 = "0z46k143ppf9mz3jw8wqw91z93gx79jy0gcdfrhl3m6nqw27li08";
    };
  };
})
