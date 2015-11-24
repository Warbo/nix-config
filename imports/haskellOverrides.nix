pkgs: hsPkgs:
  let mkPkg = x: old:
      let n = pkgs.lib.removeSuffix ".nix" x;
       in old // builtins.listToAttrs [{
                   name  = n;
                   value = hsPkgs.callPackage (./haskell + "/${n}.nix") {};
                 }];
   in pkgs.lib.fold mkPkg
           {}
           (builtins.filter (pkgs.lib.hasSuffix ".nix")
                   (builtins.attrNames (builtins.readDir ./haskell)))
