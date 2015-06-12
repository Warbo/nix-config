{ mkDerivation, base, containers, random, stdenv, template-haskell
, test-framework, tf-random, transformers
}:
mkDerivation {
  pname = "QuickCheck";
  version = "2.8.1";
  sha256 = "0fvnfl30fxmj5q920l13641ar896d53z0z6z66m7c1366lvalwvh";
  buildDepends = [
    base containers random template-haskell tf-random transformers
  ];
  testDepends = [ base containers template-haskell test-framework ];
  homepage = "https://github.com/nick8325/quickcheck";
  description = "Automatic testing of Haskell programs";
  license = stdenv.lib.licenses.bsd3;
}
