{ haskellPackages, tincify }:

tincify (haskellPackages.ML4HSFE // { extras = [ "HS2AST" ]; }) {}
