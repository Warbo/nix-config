self: super:

with { fetchFromGitHub = import ../nix/fetchFromGitHub.nix; };
{
  overrides = import (fetchFromGitHub {
    owner = "nix-community";
    repo = "emacs-overlay";
    rev = "272324023f7740c2c615b42283d46770f9b24bc2";
    sha256 = "0h6zvm45awa359hs52kcpdm7lybrwbxmqd44qz240bflkmjyh9l5";
  }) self super;
}
