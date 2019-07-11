{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "66d964e";
    sha256 = "0zxxpf5a3hjfjjqi4nrfbdlkrqn2jpcg98v0affrkbmx9piy1w8h";
  };
}
