{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "bd43761";
    sha256 = "1kz496h3s3jfbiy17d7z54qgy5vk4ijlyw235rdmxwls3jnr7rg4";
  };
}
