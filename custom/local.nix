# Turn files of the form "./local/foo.nix" into packages "foo" using callPackage
self: super:

with builtins;
with super.lib;
with rec {
  callPackage = super.newScope self;
  extraArgs   = args: (if args ? self  then { inherit self;  }
                                       else {}) //
                      (if args ? super then { inherit super; }
                                       else {});
  mkPkg       = x: old:
    with rec {
      func = import (./local + "/${x}");
    };
    old // listToAttrs [{
             name  = removeSuffix ".nix" x;
             value = callPackage func (extraArgs (functionArgs func));
           }];
};
fold mkPkg
     { inherit callPackage; }
     (filter (hasSuffix ".nix")
             (attrNames (readDir ./local)))
