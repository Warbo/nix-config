# Turn files of the form "./pkgs/foo.nix" into packages "foo" using callPackage
pkgs: with pkgs; with lib;
  let mkPkg = x: old:
      let n = removeSuffix ".nix" x;
       in old // builtins.listToAttrs [{
                   name  = n;
                   value = callPackage "${./pkgs}/${n}.nix" {};
                 }];
   in fold mkPkg
           {}
           (filter (hasSuffix ".nix")
           (builtins.attrNames (builtins.readDir ./pkgs)))
