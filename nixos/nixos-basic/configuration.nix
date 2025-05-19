{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    (import /home/chrisw/extra.nix)
    (import ../modules/warbo.nix)
    (import "${import ../../home-manager/nixos-import.nix}/nixos")
  ];
  extra.enable = true;
  boot.isContainer = true;
  networking = {
    # Disable all sorts of stuff, so we use the host (Ubuntu) networking
    hostName = lib.mkDefault "nixos-basic";
    useDHCP = false;
    useHostResolvConf = true;
    useNetworkd = false;
    firewall.enable = false;
  };
  system.stateVersion = "24.11";

  # Files in /etc will be put in place by an activation script. By default, they
  # are symlinks to /etc/static/foo, which in turn are symlinks into /nix/store.
  # However, if there is an etc/os-release in the container's rootfs, then
  # systemd/machinectl/whatever tries to read its contents during startup. Not a
  # problem at initial startup (since there isn't such an entry), but once the
  # activation script has created it, the attempt to read its contents will look
  # in /etc/static on the *host*, which doesn't make sense.
  # To avoid that, we use mode = direct-symlink, which avoids that intermediate
  # /etc/static layer and instead points straight into the Nix store (which the
  # host *will* have, since they share the same store). This also required me to
  # manually delete the dodgy etc/os-release symlink, and make a direct one,
  # since the actication script couldn't do it for me when the machine couldn't
  # start up!
  environment.etc.os-release.mode = "direct-symlink";

  environment.variables = {
    DISPLAY = ":0";
    PAGER = "cat";
  };

  warbo.enable = true;
  warbo.professional = true;
  warbo.wsl = true;
  warbo.packages = with pkgs; [
    devCli
    mediaGui
    netCli
    netGui
    sysCli
  ];
  warbo.nixpkgs.overlays = os: [
    os.repos
    os.fixes
    os.metaPackages
    os.theming
  ];

  i18n.defaultLocale = "en_GB.UTF-8";
  security.sudo.wheelNeedsPassword = false;
  users.users.chrisw = {
    isNormalUser = true;
    home = "/home/chrisw";
    description = "Chris Warburton";
    extraGroups = [
      "wheel"
      "networkmanager"
      "nix-users"
      "nscd" # Same gid as nix-users on our host. Eww...
    ];
    uid = 1000;
  };

  nix = {
    extraOptions = ''experimental-features = nix-command flakes'';
    nixPath = with builtins; [
      "nixos-config=/etc/nixos/configuration.nix"
    ];
    settings = {
      trusted-users = [
        "root"
        "@wheel"
        "@nix-users"
      ];
    };
  };

  system.activationScripts.container.text = ''
    mkdir -p /tmp/.X11-unix
    ln -sfn /mnt/tmp_.X11-unix/X0 /tmp/.X11-unix/X0
  '';

  # Required to run dodgy Linux executables provided by Windows applications
  # (e.g. 1Password's op-ssh-sign-wsl)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [ ];
  };

  services = {
    emacs.enable = true;
    ollama.enable = true;
  };
}
