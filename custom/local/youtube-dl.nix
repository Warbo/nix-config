{ callPackage, getNixpkgs }:

with rec {
  repo = (getNixpkgs {
    rev    = "86eb017";
    sha256 = "1jf5824dyqjsbpnp11kbqfqv11qllgpiy2klgdpy2z2hy6pwgipy";
  }).repo;

  pycryptodome =
    callPackage "${repo}/pkgs/development/python-modules/pycryptodome" {};
};
callPackage "${repo}/pkgs/tools/misc/youtube-dl" { inherit pycryptodome; }
