# Warbo's NixOS Configuration #

This is the configuration I use for NixOS. It makes heavy use of the following:

 - `http://chriswarbo.net/git/nix-helpers` provides useful Nix functions
 - `http://chriswarbo.net/git/warbo-packages` packages up useful 3rd-party stuff
 - `http://chriswarbo.net/git/warbo-utilities` provides my own utility scripts

In general, I try to define as much as possible in the above projects, so that
they are more widely/generally useful. This repository contains "left overs"
which are quite specific to system configuration (e.g. system services, user
profiles, etc.).

I use this configuration by symlinking `/etc/nixos/configuration.nix` to this
repository's `nixos/configuration.nix` file. You can also symlink the repository
directory to `~/.config/nixpkgs`, which will cause `overlays.nix` to be loaded
automatically when your user invokes Nix commands. You could also load it
separately, e.g. via an `import`.
