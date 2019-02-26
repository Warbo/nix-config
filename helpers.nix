{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "fa608cb";
    sha256 = "0js2wadpja02nqc4h0wki22kmgkxpyk4mwlldyxfagkkm7wk85mr";
  };
}
