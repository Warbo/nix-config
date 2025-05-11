self: super:
with rec {
  src = self.fetchFromGitHub {
    owner = "NixOS";
    repo = "nix";
    rev = "e3a8e43600c2bf17ce72d04b5235397a8725817b";
    hash = "sha256-R+HAPvD+AjiyRHZP/elkvka33G499EKT8ntyF/EPPRI=";
  };
  backported-2_28 = (import src).default;
  redundant = super.nixVersions ? nix_2_28;
  warn =
    if redundant then
      builtins.trace "WARNING: Backport of Nix 2.28 is redundant"
    else
      (x: x);
}; {
  overrides.nix-backport = warn backported-2_28;
}
