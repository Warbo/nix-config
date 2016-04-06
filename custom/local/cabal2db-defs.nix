{ cabal2db, stdenv, haskellPackages, nix, jq }:

import "${cabal2db}/lib/defs.nix" { inherit stdenv haskellPackages nix jq cabal2db; }
