self: super:

with builtins;
with super.lib;
with rec {
  # Names of every ".nix" file in overrides/ (this must not depend on 'self')
  fileNames = map (removeSuffix ".nix")
                  (filter (hasSuffix ".nix")
                          (attrNames (readDir ./overrides)));

  mkPkg = f: oldPkgs:
    with { this = import (./. + "/overrides/${f}.nix") self super; };
    oldPkgs // this.overrides // {
      nix-config-checks = oldPkgs.nix-config-checks // (this.checks or {});
      nix-config-names  = oldPkgs.nix-config-names ++ attrNames this.overrides;
      nix-config-tests  = oldPkgs.nix-config-tests // { "${f}" = this.tests; };
    };
};
fold mkPkg
  {
    nix-config-checks = {};
    nix-config-names  = [ "nix-config-tests" ];
    nix-config-tests  = {};
  }
  fileNames
