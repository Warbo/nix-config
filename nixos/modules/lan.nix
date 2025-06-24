{ config, lib, pkgs, ... }:
with rec {
  inherit (lib)
    mkIf
    mkMerge
  ;

  username = config.warbo.home-manager.username or null;

  shared = {
    device = "//s5.local/shared";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.mount-timeout=5s"
      "user"
      "users"
    ];
  };
};
{
  config = mkMerge [
    { system.fsPackages = [ pkgs.cifs-utils pkgs.getent pkgs.rclone ]; }

    (mkIf (username != null) {
      fileSystems."/home/${username}/Public" = shared;
    })

    })
  ];
}
