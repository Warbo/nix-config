self: super:

with self;
with {
  repoHack = runCommand "repo-hack" {} ''
    mkdir -p "$out"
    cp -r "${stableRepo}" "$out/nixpkgs"
  '';
};
import (runCommand "get" {
    buildInputs = [ cabal2nix cabal-install nix-prefetch-scripts nix ];
    NIX_REMOTE  = "daemon";
    NIX_PATH    = builtins.getEnv "NIX_PATH" + ":${repoHack}";
  }
  ''
    export HOME="$PWD"
    cabal update
    cabal2nix cabal://structural-induction-0.3 > "$out"
  '')
