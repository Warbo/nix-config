{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "a92a9dd";
    sha256 = "1ykr3n36in8n7jgkg928891b7mvdi5izi807c8jbyqxnwcqqzzs7";
  };
}
