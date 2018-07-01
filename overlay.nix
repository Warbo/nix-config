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
    oldPkgs // mapAttrs (n: trace "Evaluating ${n}") overrides // {
      customPkgNames = oldPkgs.customPkgNames ++ attrNames overrides;
      customTests    = oldPkgs.customTests    // { "${f}" = tests; };
    };
};
fold mkPkg { customTests = {}; } fileNames
