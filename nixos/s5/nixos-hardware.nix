with { fetchFromGitHub = import ../../nix/fetchFromGitHub.nix; };
fetchFromGitHub {
  owner = "nixos";
  repo = "nix-hardware";
  rev = "672ac2ac86f7dff2f6f3406405bddecf960e0db6";
  sha256 = "sha256-UhWmEZhwJZmVZ1jfHZFzCg+ZLO9Tb/v3Y6LC0UNyeTo=";
}
