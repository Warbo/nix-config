# Augments <original> to act like <nixpkgs>, so we don't have to be located in
# ~/.nixpkgs. This is mostly useful for testing, e.g. via Hydra; regular usage
# can just use ~/.nixpkgs as intended.

import <original> {
  config = {
    packageOverrides = import ./custom.nix;
  };
}
