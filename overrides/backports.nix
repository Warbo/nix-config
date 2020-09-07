# Overrides for packages which are too old to appear in the latest nixpkgs
# version. We only do this when the packaged version doesn't actually work
# anymore, e.g. if some Web site has changed its protocol.
# All of these overrides are meant to be temporary, so each one should perform a
# check to see if it's still needed. These checks should:
#  - Look in the 'latest' nixpkgs set, rather than hard-coding some particular
#    version of nixpkgs. This prevents bit rot as new versions are added.
#  - Use 'trace' to warn us, rather than an assertion. This is because we might
#    want to use a pinned nix-config somewhere, and there's no point causing
#    such pinned versions to break in the future.
self: super:

with {
  inherit (builtins) compareVersions fetchurl foldl' getAttr mapAttrs toJSON;
  inherit (super.lib) concatStringsSep genAttrs makeOverridable optional;
};
{
  overrides = {
    # Take nix-helper's Niv version
    niv = self.pinnedNiv;

    firefoxBinary = self.makeFirefoxBinary self.nix-config-sources.firefox;

    nix-config-version-check = name: { extra ? [], script, url, version }:
      with {
        latest = import (self.runCommand "latest-${name}.nix"
                                         { page = fetchurl url; }
                                         script);
      };
      extra ++ optional
        (self.onlineCheck && compareVersions version latest == -1)
        (toJSON {
          inherit latest version;
          WARNING = "Newer ${name} is available";
        });
  };

  checks =
    genAttrs [ "nix-helpers" "warbo-packages" "warbo-utilities" ] (name:
      with rec {
        src  = getAttr name self.nix-config-sources;
        got  = src.rev;
        want = self.gitHead { url = src.repo; };
      };
      optional (self.onlineCheck && (got != want)) (toJSON {
        inherit got name want;
        warning = "Pinned repo is out of date";
      }))
    //
    mapAttrs self.nix-config-version-check
      {
        firefoxBinary = {
          inherit (self.nix-config-sources.firefox) version;
          url    = https://www.mozilla.org/en-US/firefox/releases;
          script = ''
            grep -o 'data-latest-firefox="[^"]*"' < "$page" |
            grep -o '".*"' > "$out"
          '';
        };
    }
  ;
}
