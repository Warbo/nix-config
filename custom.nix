stable: pkgs:

with builtins;
with pkgs.lib;
with rec {
  mkPkg = x: oldPkgs:
    with { newPkgs = oldPkgs // import x overridden pkgs; };
    newPkgs // {
      # Keep a record of which packages are custom
      customPkgNames = attrNames newPkgs;
    };

  nixFiles =
    with { dir = ./custom; };
    map (f: dir + "/${f}")
        (filter (hasSuffix ".nix")
                (attrNames (readDir dir)));

  overridden = pkgs // overrides;
  overrides  = fold mkPkg { inherit stable; } nixFiles;
};
overrides
