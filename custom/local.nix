# Turn files of the form "./local/foo.nix" into packages "foo" using callPackage
self: super:

with super; with lib;

let mkPkg = x: old:
    old // builtins.listToAttrs [{
             name  = removeSuffix ".nix" x;
             value = callPackage (./local + "/${x}") {};
           }];
 in fold mkPkg
         {}
         (filter (hasSuffix ".nix")
                 (builtins.attrNames (builtins.readDir ./local)))
