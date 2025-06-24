# mobile-nixpkgs pins a known-good nixpkgs, so use that for our pinephone
import (import "${import ./mobile-nixos.nix}/npins").nixpkgs
