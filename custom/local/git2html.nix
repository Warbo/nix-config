{ git2html-real, latestGit, repoSource, stdenv }:

stdenv.lib.overrideDerivation git2html-real (old: {
  src = latestGit {
    url    = "${repoSource}/git2html.git";
    stable = {
      rev    = "121d5bc";
      sha256 = "0rbfpjjdfqhys85qga4js4ha5cgjdhj5dwqgkvvcki32k3sgaplf";
    };
  };
})
