{ haskellPackages }:

haskellPackages.ghcWithPackages (pkgs : [
  pkgs.xmonad
  pkgs.xmonad-extras
  pkgs.xmonad-contrib
])
