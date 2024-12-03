# Adding this to the 'imports' list of a NixOS configuration.nix will enable
# Home Manager for that NixOS system.
with { fetchFromGitHub = import ../nix/fetchFromGitHub.nix; };
fetchFromGitHub {
  owner = "nix-community";
  repo = "home-manager";
  rev = "62d536255879be574ebfe9b87c4ac194febf47c5"; # release-24.11
  sha256 = "0v9bsc6r2626kap2m12zxw47m4p2kpr4pjldr7wvgqq48vwd72cm";
}
