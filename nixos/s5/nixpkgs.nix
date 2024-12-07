# Version taken from flake.lock in github.com/NickCao/nixos-riscv. We can try
# replacing this with a "normal" NixOS/Nixpkgs release once there's one with the
# required support (notably Linux 6.11). NixOS 24.11 *might* be enough, though
# it would be safer to wait until 25.*
with {
  owner = "NixOS";
  repo = "Nixpkgs";
  rev = "276e1b72206635f5cee5e50ff66aa5ec6271b2e1";
};
builtins.fetchTarball {
  url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
  sha256 = "sha256-EW63zYHpMjh12RJdnuk41liWxE6eTkocssCReg8HgsI=";
}
