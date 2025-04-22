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
    pkgs.j2cli
    pkgs.nix-backport
    pkgs.typescript-language-server
    (pkgs.writeShellApplication {
      # nixos-container is mostly useless as a regular user but sudo needs extra
      # args to preserve required env vars, so we make this wrapper for it.
      name = "nixos-container";
      text = ''
        exec sudo env PATH="$PATH" NIX_PATH="$NIX_PATH" ${pkgs.nixos-container}/bin/nixos-container "$@"
      '';
    })
  ];
  warbo.nixpkgs.overlays = os: [
    os.repos
    os.metaPackages
    os.nix-backport
    (self: super: {
      inherit (self.nix-helpers.nixpkgs2405) openssh;
    })
  ];
  home = warbo-wsl.home // {
    username = "chrisw";
    homeDirectory = "/home/chrisw";
  };
}
