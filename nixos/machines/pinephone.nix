{
  config,
  lib,
  pkgs,
  ...
}:
{
  networking.hostName = "pinephone";

  # Phone UI
  programs.phosh.enable = true;

  # We always want immutable users, but we set it per-machine since it wasn't
  # set on thinkpad (and I don't know if it's safe to enable post-hoc?)
  users.mutableUsers = false;
}
