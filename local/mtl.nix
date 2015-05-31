{ mkDerivation, base, stdenv, transformers }:
mkDerivation {
  pname = "mtl";
  version = "2.2.1";
  sha256 = "1icdbj2rshzn0m1zz5wa7v3xvkf6qw811p4s7jgqwvx1ydwrvrfa";
  buildDepends = [ base transformers ];
  homepage = "http://github.com/ekmett/mtl";
  description = "Monad classes, using functional dependencies";
  license = stdenv.lib.licenses.bsd3;
}
