{ coq, hasBinary, latestGit, nixpkgs1609, stable, stdenv, withDeps }:

with rec {
  pkg = if stable then nixpkgs1609.coq else coq;

  patched = stdenv.lib.overrideDerivation pkg (oldAttrs : {
    name  = "coq-mtac";
    src   = latestGit {
      url    = https://github.com/beta-ziliani/coq.git;
      ref    = "SafeRefs-1.2";
      stable = {
        rev    = "2651fd3";
        sha256 = "0z46k143ppf9mz3jw8wqw91z93gx79jy0gcdfrhl3m6nqw27li08";
      };
    };
  });

  tested = withDeps [ (hasBinary patched "coqc") ] patched;
};
{
  pkg   =   tested;
  tests = [ tested ];
}
