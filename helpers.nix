{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "c9d5aa0";
    sha256 = "0pm38zsgqza8hdv2d18lspk0kbvk1a78iqmbxaydw7dv73xxxgwi";
  };
}
