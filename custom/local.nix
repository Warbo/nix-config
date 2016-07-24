# Turn files of the form "./local/foo.nix" into packages "foo" using callPackage
self: super:

with super.lib; with builtins;

let #callPkg = trace "FIXME: Can callPkg go into imports?" (super.newScope self);
    mkPkg   = x: old:
      old // listToAttrs [{
               name  = removeSuffix ".nix" x;
               value = let path = ./local + "/${x}";
                           deps = attrNames (functionArgs (import path));
                           args = (if builtins.elem "self"  deps then { inherit self;  }
                                                        else {}) //
                                  (if builtins.elem "super" deps then { inherit super; }
                                                        else {});
                        in self.callPackage path {};
             }];
 in fold mkPkg
         {}
         (filter (hasSuffix ".nix")
                 (attrNames (readDir ./local)))
