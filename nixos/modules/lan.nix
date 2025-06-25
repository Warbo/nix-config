{ config, lib, pkgs, ... }:
with rec {
  inherit (lib)
    mkIf
    mkMerge
  ;

  username = config.warbo.home-manager.username or null;

  shared = {
    device = ":smb:shared"; # Rclone SMB backend, 'shared' is the remote name
    fsType = "rclone";
    noCheck = true; # Often needed for rclone mounts
    options = [
      # General mount options
      "nodev"
      "nofail"
      "noauto"
      "allow_other"
      "_netdev"
      # SystemD-specific, useful for network mounts
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.mount-timeout=5s"
      # Rclone-specific SMB options
      "smb-host=s5.local"
      "smb-share=shared"
      "vfs-cache-mode=full"
      # smb-user and smb-pass are omitted for anonymous access
    ];
  };

  s5 = {
    device = ":sftp:/";
    fsType = "rclone";
    noCheck = true;
    options = [
      # General mount options
      "nodev"
      "nofail"
      "noauto"
      "allow_other"
      "_netdev"
      # SystemD-specific, useful for network mounts
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.mount-timeout=5s"
      # Rclone-specific
      "sftp-host=s5.local"
      "sftp-user=nixos"
      "vfs-cache-mode=full"
      "sftp-set-modtime=false" # Avoids SSH_FX_OP_UNSUPPORTED
      "no-update-modtime"
      "sftp-ciphers=aes128-ctr"
      "sftp-key-file=/home/${username}/.ssh/id_ed25519"
    ];
  };
};
{
  config = mkMerge [
    { system.fsPackages = [ pkgs.getent pkgs.rclone ]; }

    (mkIf (username != null) {
      fileSystems."/home/${username}/Public" = shared;
    })

    (mkIf (username == "chris") {
      fileSystems."/home/${username}/Mounts/s5" = s5;
    })
  ];
}
