{ mkDerivation, base, stdenv }:
mkDerivation {
  pname = "transformers";
  version = "0.4.3.0";
  sha256 = "179sbhvc9dghyw58hz80109pbrzgh7vh437227a51jhmx2bsgl5k";
  buildDepends = [ base ];
  description = "Concrete functor and monad transformers";
  license = stdenv.lib.licenses.bsd3;
}
