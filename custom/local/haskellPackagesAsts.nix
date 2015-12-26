{ ghcast, callPackage }:

let inPkgs = s: with builtins; toPath (toString <nixpkgs> + "/pkgs/" + s);
 in callPackage (inPkgs "development/haskell-modules") {
      ghc = ghcast;
      compilerConfig = callPackage (inPkgs "development/haskell-modules/configuration-ghc-7.10.x.nix") {};
    }
