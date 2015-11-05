let custom  = import ./custom.nix;
    imports = import ./imports.nix;
in {
  allowUnfree      = true;
  packageOverrides = pkgs: custom pkgs (imports pkgs);
}
