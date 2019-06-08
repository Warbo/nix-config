{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "fcc8450";
    sha256 = "0zp1s97kl7q2qcy82aassfjiqqa04jvxvw39bzgk2hd7xd8xzn24";
  };
}
