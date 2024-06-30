{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    (import ../modules/fetch-youtube.nix)
    (import ../modules/warbo.nix)
  ];
  home.username = "pi";
  home.homeDirectory = "/home/pi";
  warbo.enable = true;

  fetch-youtube = {
    enable = true;
    args = [
      "-f"
      "b[height<600]"
    ];
    timer = {
      OnBootSec = "15min";
      OnUnitActiveSec = "1d";
    };
  };

  programs.git = {
    userName = "Chris Warburton";
    userEmail = "chriswarbo@gmail.com";
  };

  # Use native, since Nix one hangs
  systemd.user.systemctlPath = "/bin/systemctl";
}
