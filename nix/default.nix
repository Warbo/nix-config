with rec {
  sources = import ./sources.nix;
  helpers = import sources.nix-helpers { };
};
import helpers.repoLatest {
  config = { };
  overlays = builtins.attrValues (import ../overlays.nix);
}
