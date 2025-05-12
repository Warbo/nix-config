# Backport of Nix with (working) git-hashing feature. See also the NixOS module
# at nixos/modules/nix-backport.nix, which can use the NixOS config to handle
# platforms and cross-compilation.
self: super:
with rec {
  nix-helpers = self.nix-helpers
    or (rec { inherit (import ../overrides/nix-helpers.nix overrides { }) overrides; })
    .overrides.nix-helpers;

  nixpkgs-src = nix-helpers.getNixpkgs {
    rev = "50a572e12ba0dd4147d9b096cc44e7e62e8ec3a6";
    sha256 = "sha256:024c6ng4bknha3fwlbpb2ghdn373sndy7saj21dv4wvxzpxp42jx";
  };

  nixpkgs = import nixpkgs-src {
    inherit (self) system;
    config = { };
    overlays = [ ];
  };

  backported-2_28 = nixpkgs.nixVersions.nix_2_28;

  warn =
    if super.nixVersions ? nix_2_28 then
      builtins.trace "WARNING: Backport of Nix 2.28 is redundant"
    else
      (x: x);
}; {
  overrides.nix-backport = warn backported-2_28 // {
    # Pass along the Nixpkgs repo so nixos/modules/nix-backport.nix can import
    # it with appropriate system arguments.
    inherit nixpkgs-src;
  };
}
