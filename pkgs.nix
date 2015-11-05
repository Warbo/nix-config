# Turn files of the form "./local/foo.nix" into packages "foo"
pkgs: with pkgs; with lib;
  let mkPkg = x: old:
      let n = removeSuffix ".nix" x;
       in old // builtins.listToAttrs [{
                   name  = n;
                   value = callPackage "${./local}/${n}.nix" {};
                 }];
   in fold mkPkg
           {}
           (filter (hasSuffix ".nix")
           (builtins.attrNames (builtins.readDir ./local)))
