{ fetchFromGitHub, hasBinary, super, withDeps }:

with rec {
  src = fetchFromGitHub {
    owner  = "Gabriel439";
    repo   = "nix-diff";
    rev    = "ece65b7";
    sha256 = "1hd43nvp8n66il4aqfysr59q4biifi53smimfcv9mh3i0jli4hj5";
  };

  pkgs = import "${src}/release.nix";

  pkg  = pkgs.nix-diff;

  haveBin = hasBinary pkg "nix-diff";

  warn = if super.haskellPackages ? nix-diff
            then builtins.trace ''
                   WARNING: nix-diff was found in haskellPackages; our custom
                            definition may be obsolete now.
                 ''
            else (x: x);
};
withDeps [ haveBin ] (warn pkg)
