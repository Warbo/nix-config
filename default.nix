# Regular Nix users can ignore this file, and just use config.nix via the normal
# ~/.nixpkgs override mechanism.

# When building on Hydra we can't rely on ~, so we need to reimplement the
# packageOverride mechanism. To do this, we need to ensure that <nixpkgs> is an
# overridden set of packages (to allow arbitrary dependencies), but also ensure
# that ./custom.nix is given a non-overriden pkgs argument (to avoid circular
# dependencies).

# We assume that <original> is a non-overridden set of packages, e.g. a git
# checkout of nixpkgs, which might be a Hydra build input. We give this to
# ./custom.nix as its pkgs argument (see also ./release.nix).

# This file (./default.nix) provides the overridden package set for us to use as
# <nixpkgs>; since this file will be loaded by default, we can use a checkout of
# this git repository as <nixpkgs> (e.g. via a Hydra build input).

args:

import <original> ({
  config = {
    packageOverrides = import ./custom.nix;
  };
} // args)
