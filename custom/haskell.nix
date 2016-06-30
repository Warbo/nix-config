# Override Haskell packages using haskell/*.nix
with import <nixpkgs> {};

pkgs:

# Add everything from haskell/ to haskellPackages
let haskellOverrides = hsPkgs:
    let mkPkg = x: old:
        let n = pkgs.lib.removeSuffix ".nix" x;
         in old // builtins.listToAttrs [{
                     name  = n;
                     value = hsPkgs.callPackage (./haskell + "/${n}.nix") {};
                   }];
     in pkgs.lib.fold mkPkg
                      {}
                      (builtins.filter (pkgs.lib.hasSuffix ".nix")
                                       (builtins.attrNames (builtins.readDir ./haskell)));

  overrideHaskellPkgs = hsPkgs:
      hsPkgs.override {
        overrides = self: super: haskellOverrides self;
      };
in {
  # Latest
  haskellPackages = overrideHaskellPkgs pkgs.haskellPackages;

  # GHC 7.8.4
  haskell = pkgs.haskell // {
    packages = pkgs.haskell.packages // {
      ghc784 = overrideHaskellPkgs pkgs.haskell.packages.ghc784;
    };
  };

  # The haskellPackages from stable, but augmented with our overrides. Useful if
  # the unstable haskellPackages are broken through no fault of ours.
  stableHaskellPackages = overrideHaskellPkgs stable.haskellPackages;
}
