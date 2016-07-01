# Import files of the form "./imports/foo.nix" into attributes "foo"
self: super:

with super; with lib;
let mkPkg = x: old:
    let n = removeSuffix ".nix" x;
     in old // builtins.listToAttrs [{
                 name  = n;
                 value = import (./imports + "/${n}.nix");
               }];
 in fold mkPkg
         {}
         (filter (hasSuffix ".nix")
                 (builtins.attrNames (builtins.readDir ./imports)))
