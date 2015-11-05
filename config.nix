let custom  = import ./custom.nix;
    local   = import ./local.nix;
    helpers = import ./helpers.nix;
in {
  allowUnfree      = true;
  packageOverrides = given: let pkgs = given // helpers;
                             in custom pkgs (local pkgs);
}
