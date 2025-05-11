# Assign each NixOS configuration to its associated machine, so they can all be
# applied/deployed at once using Colmena.
{
  meta = {
    name = "warbo-nix-config";
    description = "Applies NixOS configurations to various machines";
  };

  # This module will be imported by all hosts
  defaults = { pkgs, ... }: {
    # Don't replace unknown remote profiles. This can maybe be removed once we
    # have everything working with Colmena smoothly.
    deployment.replaceUnknownProfiles = true;
  };

  # TODO: Gradually move more machines into here!
  "nixos-amd64.local" = import ./nixos/nixos-amd64/configuration.nix;
  "chromebook.local" = import ./nixos/chromebook/configuration.nix;
}
