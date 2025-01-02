# Version taken from flake.lock in github.com/NickCao/nixos-riscv. We can try
# replacing this with a "normal" NixOS/Nixpkgs release once there's one with the
# required support (notably Linux 6.11). NixOS 24.11 *might* be enough, though
# it would be safer to wait until 25.*
with { fetchFromGitHub = import ../../nix/fetchFromGitHub.nix; };
fetchFromGitHub {
  owner = "NixOS";
  repo = "Nixpkgs";
  rev = "003998619b45e244f23d1cb69f92de9a0adf7635";
  sha256 = "sha256-aMc3rjeLxsF7SViuiC8/4eLvZjLQav9fi4mJbhiZxDM=";
}
