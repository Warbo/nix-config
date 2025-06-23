{ config, lib, pkgs, ... }:
with {
  defaultUserName = "chris";
  mobile-nixos = import ./mobile-nixos.nix;
};
{
  imports = import "${mobile-nixos}/modules/module-list.nix" ++ [
    "${mobile-nixos}/devices/pine64-pinephone"
    ../modules/warbo.nix
  ];

  mobile = {
    boot.stage-1.networking.enable = lib.mkDefault true;
    beautification = {
      silentBoot = lib.mkDefault true;
      splash = lib.mkDefault true;
    };
  };

  nix = {
    extraOptions = ''experimental-features = ${
      lib.concatStringsSep " " [
        "configurable-impure-env"
        "flakes"
        "git-hashing"
        "nix-command"
      ]
    }'';
    nixPath = with builtins; [
      "nixos-config=${toString ../..}/nixos/pinephone/configuration.nix"
    ];
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
  };
  nixpkgs.overlays = [
    (self: super: {
      libchewing =
        # Marked as broken, and removed in later Nixpkgs
        (if super ? libchewing
         then (x: x)
         else builtins.trace "WARNING: libchewing override may not be needed")
          null;
    })
  ];
  hardware = {
    bluetooth.enable = true;
  };
  networking = {
    hostName = "pinephone";
    networkmanager.enable = true;
    networkmanager.unmanaged = [ "rndis0" "usb0" ];
    wireless.enable = false;
  };
  powerManagement.enable = true;

  environment.systemPackages = [
    pkgs.colmena
  ] ++ builtins.attrValues pkgs.widgetThemes;

  services = {
    displayManager = {
      autoLogin = {
        enable = true;
        user = defaultUserName;
      };
      defaultSession = "plasma-mobile";
    };
    xserver = {
      enable = true;
      xkb.layout = "gb";
      xkb.options = "ctrl:nocaps";
      desktopManager.plasma5.mobile.enable = true;

      displayManager.lightdm = {
        enable = true;
        # Workaround for autologin only working at first launch.
        # A logout or session crashing will show the login screen otherwise.
        extraSeatDefaults = ''
          session-cleanup-script=${pkgs.procps}/bin/pkill -P1 -fx ${pkgs.lightdm}/sbin/lightdm
        '';
      };
    };
    avahi.hostName = config.networking.hostName;
    libinput.enable = true;
    openssh.enable = true;
    pipewire.enable = lib.mkDefault true;
    pulseaudio.enable = lib.mkDefault false;
  };
  system.stateVersion = "25.11";

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    #   font = "Lat2-Terminus16";
    keyMap = "uk";
    #   useXkbConfig = true; # use xkb.options in tty.
  };

  users.users.${defaultUserName} = {
    isNormalUser = true;
    # Numeric pin makes it possible to input on the lockscreen.
    password = "123";
    home = "/home/${defaultUserName}";
    extraGroups = [
      "dialout"
      "feedbackd"
      "networkmanager"
      "video"
      "wheel"
    ];
    uid = 1000;
  };

  warbo.enable = true;
  warbo.home-manager.username = "chris";
  warbo.packages = with pkgs; [
    devCli
    netCli
    sysCli
  ];
  warbo.nixpkgs = {
    path = (import "${mobile-nixos}/npins").nixpkgs.outPath;
    overlays = os: [
      os.repos
      os.fixes
      os.metaPackages
      os.theming
    ];
  };
}
