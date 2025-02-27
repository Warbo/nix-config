{
  config,
  lib,
  pkgs,
  ...
}:

{
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

  users.users.chrisw = {
    isNormalUser  = true;
    home = "/home/chrisw";
    description = "Chris Warburton";
    extraGroups = [ "wheel" "networkmanager" ];
    uid = 1000;
  };

  services = {
    ollama.enable = true;
  };
}
