self: super:

with self;
import (runCommand "get" {
    buildInputs = [ cabal2nix cabal-install nix-prefetch-scripts nix ];
    NIX_REMOTE  = "daemon";
    NIX_PATH    = builtins.getEnv "NIX_PATH" + ":${stableRepo}";
  }
  ''
    export HOME="$PWD"
    cabal update
    cabal2nix cabal://structural-induction-0.3 > "$out"
  '')
