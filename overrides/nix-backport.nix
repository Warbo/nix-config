self: super:
with rec {
  src = self.fetchFromGitHub {
    owner = "NixOS";
    repo = "nix";
    rev = "e3a8e43600c2bf17ce72d04b5235397a8725817b";
    hash = "sha256-R+HAPvD+AjiyRHZP/elkvka33G499EKT8ntyF/EPPRI=";
  };
  backported-2_28 =
    if self.lib.hasPrefix "riscv" self.targetSystem
    then (import src).hydraJobs.buildCross.nix-everything.riscv64-unknown-linux-gnu.x86_64-linux
    else (import src).default;
  redundant = super.nixVersions ? nix_2_28;
  warn =
    if redundant then
      builtins.trace "WARNING: Backport of Nix 2.28 is redundant"
    else
      (x: x);
}; {
  overrides.nix-backport = warn backported-2_28;
}
