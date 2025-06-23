## Warbo's NixOS PinePhone Config ##

This is designed to run from a microSD card in an original PinePhone (not Pro).
It's built on mobile-nixos.

### `default.nix` ###

This loads a known-good revision of mobile-nixos, gives it our configuration and
returns a bootable PinePhone disk image.

### `configuration.nix` ###

This should be a mostly-ordinary NixOS configuration, although some options may
be specific to mobile-nixos. Ideally, it should be possible for the PinePhone to
alter and update itself via the usual `nixos-rebuild switch` (and maybe even
`colmena apply`), although that's not been tested yet.

### `u-boot-sunxi-with-spl-528.bin` ###

This is a pre-built U-Boot image taken from `usr/share/u-boot/pine64-pinephone/`
in the postmarketOS package `u-boot-pinephone-2023.01-r4.apk`. Our `default.nix`
will write this to the start of our generated microSD image, so it can boot with
the PinePhone's stock U-Boot (without this, NixOS would need Tow-Boot on the
PinePhone).
