let custom  = import ./custom.nix;
    local   = import ./pkgs.nix;
    imports = import ./imports.nix;
in {
  allowUnfree      = true;
  packageOverrides = given: let pkgs = given // imports;
                             in custom pkgs (local pkgs);
}
