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
  mkPkg = x: old:
    with rec {
      func     = import (./local + "/${x}");
      result   = callPackage func (extraArgs (functionArgs func));
      hasTests = isAttrs result         &&
                 hasAttr "pkg"   result &&
                 hasAttr "tests" result;
    };
    {
      pkgs = old.pkgs // listToAttrs [{
               name  = removeSuffix ".nix" x;
               value = if hasTests
                          then result.pkg
                          else result;
             }];

      tests = old.tests ++ (if hasTests
                               then result.tests
                               else []);
    };
};
fold mkPkg
     {
       pkgs  = { inherit callPackage; };
       tests = [];
     }
     (filter (hasSuffix ".nix")
             (attrNames (readDir ./local)))
