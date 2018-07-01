# Turn files of the form "./local/foo.nix" into packages "foo" using callPackage
self: super:

with builtins;
with super.lib;
with rec {
  mkPkg = name: old:
    with rec {
      func     = import (./local + "/${name}.nix");
      result   = self.newScope { inherit self super; } func {};
      hasTests = isAttrs result         &&
                 hasAttr "pkg"   result &&
                 hasAttr "tests" result;
    };
    {
      overrides = old.overrides // listToAttrs [{
               inherit name;
               value = if hasTests
                          then result.pkg
                          else result;
             }];

      tests = old.tests // (if hasTests
                               then { "${name}" = result.tests; }
                               else {});
    };
};
fold mkPkg
     {
       overrides  = {};
       tests      = {};
     }
     (map (removeSuffix ".nix")
          (filter (hasSuffix ".nix")
                  (attrNames (readDir ./local))))
