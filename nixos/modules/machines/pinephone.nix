{ config, lib, pkgs, ... }: {
  networking.hostname = "pinephone";
  # We always want immutable users, but we set it per-machine since it wasn't
  # set on thinkpad (and I don't know if it's safe to enable post-hoc?)
  users.mutableUsers = false;
}
