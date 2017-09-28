import ./other.nix // {
  packageOverrides = import ./custom.nix true;
}
