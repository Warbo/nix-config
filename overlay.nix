self: super:

with builtins;
with rec {
  inherit (super) lib;

  stableVersion = import ./stableVersion.nix;

  # All of the files containing our overrides
  nixFiles = self.nixFilesIn ./overrides;

  mkPkg = f: oldPkgs:
    with self.newScope { inherit super; } (getAttr f nixFiles) {};
    oldPkgs // result.pkgs // {
      customPkgNames = attrNames newPkgs;
      customTests    = oldPkgs.customTests // { "${f}" = result.tests; };
    };
};
lib.fold mkPkg { customTests = {}; } (attrNames nixFiles)
