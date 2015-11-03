let custom = import ./custom.nix;
    local  = import ./local.nix;
in {
  allowUnfree      = true;
  packageOverrides = pkgs: custom pkgs (local pkgs);
}
