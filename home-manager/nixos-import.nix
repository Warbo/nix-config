# Adding this to the 'imports' list of a NixOS configuration.nix will enable
# Home Manager for that NixOS system.
with { fetchFromGitHub = import ../nix/fetchFromGitHub.nix; };
fetchFromGitHub {
  owner = "nix-community";
  repo = "home-manager";
  rev = "7aae0ee71a17b19708b93b3ed448a1a0952bf111"; # release-25.05
  sha256 = "12246mk1xf1bmak1n36yfnr4b0vpcwlp6q66dgvz8ip8p27pfcw2";
}
