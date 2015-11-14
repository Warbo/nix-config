pkgs: hsPkgs:
  with pkgs; with lib;
  let mkPkg = x: old:
      let n = removeSuffix ".nix" x;
       in old // builtins.listToAttrs [{
                   name  = n;
                   value = hsPkgs.callPackage (./haskell + "/${n}.nix") {};
                 }];
   in fold mkPkg
           {}
           (filter (hasSuffix ".nix")
                   (builtins.attrNames (builtins.readDir ./haskell)))
