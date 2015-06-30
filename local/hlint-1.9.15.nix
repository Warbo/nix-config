{ mkDerivation, ansi-terminal, base, cmdargs, containers, cpphs
, directory, extra, filepath, haskell-src-exts, hscolour, process
, stdenv, transformers, uniplate
}:
mkDerivation {
  pname = "hlint";
  version = "1.9.15";
  sha256 = "0fn01rhymj9hy7pglrjkgs4cz8xsllmc2zdnjrb6n6k27644irdw";
  isLibrary = true;
  isExecutable = true;
  buildDepends = [
    ansi-terminal base cmdargs containers cpphs directory extra
    filepath haskell-src-exts hscolour process transformers uniplate
  ];
  homepage = "http://community.haskell.org/~ndm/hlint/";
  description = "Source code suggestions";
  license = stdenv.lib.licenses.bsd3;
}
