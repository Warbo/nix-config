{
  allowUnfree      = true;
  packageOverrides = pkgs:
    with pkgs; with lib;
    let mkPkg = x: old:
       let n = removeSuffix ".nix" x;
        in old // (import (./custom + "/${n}.nix") pkgs);
     in fold mkPkg
             {}
             (filter (hasSuffix ".nix")
                     (builtins.attrNames (builtins.readDir ./custom)));
}
