{
  config,
  pkgs,
  lib,
  ...
}:

with {
  warbo-wsl = import ../../wsl { inherit lib pkgs; };
};
warbo-wsl.config // {
  imports = [ (../modules/warbo.nix) ];

  warbo.enable = true;
  warbo.professional = true;
  warbo.home-manager.stateVersion = "24.05";
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

  # Let Home Manager install and manage itself.
  programs = {
    inherit (warbo-wsl) bash;
    git.extraConfig.safe.directory = "*";
    git.includes =
      # Look for existing .gitconfig files on WSL. If exactly 1 WSL user has
      # a .gitconfig file, include it.
      with builtins;
      with rec {
        inherit
          (
            (rec { inherit (import ../../overrides/repos.nix overrides { }) overrides; })
            .overrides.nix-helpers
          )
          sanitiseName
          ;
        # Look for any Windows users
        wslDir = /mnt/c/Users;
        userDirs = if pathExists wslDir then readDir wslDir else { };
        # See if any has a .gitconfig file
        userCfg = name: wslDir + "/${name}/.gitconfig";
        users = filter (
          name: userDirs."${name}" == "directory" && pathExists (userCfg name)
        ) (attrNames userDirs);
      };
      assert
        length users < 2
        || abort "Ambiguous .gitconfig, found multiple: ${toJSON users}";
      lib.lists.optional (length users == 1) {
        # Nix store paths can't begin with ".", so use contents = readFile
        path = path {
          path = userCfg (head users);
          name = sanitiseName "gitconfig-${head users}";
        };
      };

    # TODO: Put me in warbo.nix HM module (when not is-nixos?)
    home-manager = {
      path = import ../nixos-import.nix;
    };
  };
}
