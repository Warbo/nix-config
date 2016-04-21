{ recurseIntoAttrs, callPackage, nodejs, npm2nix, runScript, storeResult }:

# http://www.reddit.com/r/NixOS/comments/3w36n8/installing_npm_packages_with_nix
let faucetDef = runScript { buildInputs = [ npm2nix ]; } ''
                  npm2nix <(echo '["faucet"]') faucet.nix
                  "${storeResult}" faucet.nix "$out"
                '';
    nodepath  = <nixpkgs> + "/pkgs/top-level/node-packages.nix";
    self      = recurseIntoAttrs (callPackage nodepath {
                  inherit nodejs self;
                  generated = callPackage faucetDef { inherit self; };
                  overrides = { "faucet" = { passthru.nodePackages = self; }; };
                });
 in self.faucet
