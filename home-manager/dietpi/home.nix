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
  warbo.nixpkgs.overlays = os: [
    os.repos
    os.metaPackages
    os.nixpkgsUpstream
    os.yt-dlp
  ];

  fetch-youtube = {
    enable = true;
    destination = /opt/shared/TODO/Videos;
    args = [
      "-f"
      "b[height<600]"
    ];
    timer = {
      OnBootSec = "5min";
      OnUnitActiveSec = "6h";
    };
  };

  programs.git = {
    userName = "Chris Warburton";
    userEmail = "chriswarbo@gmail.com";
  };

  # Use native, since Nix one hangs
  systemd.user.systemctlPath = "/bin/systemctl";
}
