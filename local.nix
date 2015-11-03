pkgs: with pkgs; with lib;
  let mkPkg = x: old:
      let n = removeSuffix ".nix" x;
       in old // builtins.listToAttrs [{
                   name  = n;
                   value = callPackage "${./local}/${n}.nix" {};
                 }];
   in fold mkPkg
           pkgs
           (filter (hasSuffix ".nix")
           (builtins.attrNames (builtins.readDir ./local)))
