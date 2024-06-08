with rec {
  sources = import ./sources.nix;
  helpers = import sources.nix-helpers { };
};
import helpers.repoLatest {
  overlays = builtins.attrValues (import ../overlays.nix);
}
