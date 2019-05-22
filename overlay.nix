self: super:

with builtins;
with super.lib;
with rec {
  # Names of every ".nix" file in overrides/ (this must not depend on 'self')
  fileNames = map (removeSuffix ".nix")
                  (filter (hasSuffix ".nix")
                          (attrNames (readDir ./overrides)));

  mkPkg = f: oldPkgs:
    with import (./. + "/overrides/${f}.nix") self super;
    oldPkgs // overrides // {
      nix-config-names = oldPkgs.nix-config-names ++ attrNames overrides;
      nix-config-tests = oldPkgs.nix-config-tests // { "${f}" = tests; };
    };
};
fold mkPkg
     { nix-config-names = [ "nix-config-tests" ]; nix-config-tests = {}; }
     fileNames
