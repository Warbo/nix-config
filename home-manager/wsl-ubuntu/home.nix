{
  config,
  pkgs,
  lib,
  ...
}:

with { warbo-wsl = import ../../wsl { inherit lib pkgs; }; };
warbo-wsl.config
// {
  inherit (warbo-wsl) programs;

  imports = [ (../modules/warbo.nix) ];

  warbo.enable = true;
  warbo.professional = true;
  warbo.packages = warbo-wsl.packages ++ [
    (pkgs.hiPrio pkgs.moreutils) # prefer timestamping 'ts' on WSL
    pkgs.devCli
    pkgs.devGui
    pkgs.sysCliNoFuse
    pkgs.haskellPackages.fourmolu
    pkgs.haskellPackages.implicit-hie
    pkgs.haskellPackages.stylish-haskell
    pkgs.nix
  ];
  home = warbo-wsl.home // {
    username = "chrisw";
    homeDirectory = "/home/chrisw";
  };
}
