{ mkDerivation, array, base, containers, cpphs, directory, filepath
, ghc-prim, happy, mtl, pretty, smallcheck, stdenv, syb, tasty
, tasty-golden, tasty-smallcheck
}:
mkDerivation {
  pname = "haskell-src-exts";
  version = "1.16.0.1";
  sha256 = "1h8gjw5g92rvvzadqzpscg73x7ajvs1wlphrh27afim3scdd8frz";
  buildDepends = [ array base cpphs ghc-prim pretty ];
  testDepends = [
    base containers directory filepath mtl smallcheck syb tasty
    tasty-golden tasty-smallcheck
  ];
  buildTools = [ happy ];
  homepage = "https://github.com/haskell-suite/haskell-src-exts";
  description = "Manipulating Haskell source: abstract syntax, lexer, parser, and pretty-printer";
  license = stdenv.lib.licenses.bsd3;
}
