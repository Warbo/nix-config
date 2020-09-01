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

    get_iplayer =
      with rec {
        src = self.nix-config-sources.get_iplayer;

        get_iplayer_real = { ffmpeg, get_iplayer, perlPackages }:
          self.stdenv.lib.overrideDerivation get_iplayer
            (oldAttrs : {
              name                  = "get_iplayer-${src.version}";
              src                   = src.outPath;
              propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
                perlPackages.LWPProtocolHttps
                perlPackages.XMLSimple
                ffmpeg
              ];
            });

        mkPkg = { ffmpeg, get_iplayer, perlPackages }: self.buildEnv {
          name  = "get_iplayer-${src.version}";
          paths = [
            (get_iplayer_real { inherit ffmpeg get_iplayer perlPackages; })
            ffmpeg
            perlPackages.LWPProtocolHttps
            perlPackages.XMLSimple
          ];
        };

        # Some dependencies seem to be missing, so bundle them in with get_iplayer
        pkg = makeOverridable mkPkg {
          inherit (super) ffmpeg get_iplayer perlPackages;
        };

        test = self.hasBinary pkg "get_iplayer";
      };
      self.withDeps [ test ] pkg;

    youtube-dl =
      with rec {
        src = self.nix-config-sources.youtube-dl;

        override = super.youtube-dl.overrideDerivation (old: {
          inherit (src) version;
          name = "youtube-dl-${src.version}";
          src  = src.outPath;
        });
      };
      foldl' (x: msg: trace msg x) override self.nix-config-checks.youtube-dl;
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
    mapAttrs
      (name: { extra ? [], script, url, version }:
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
          }))
      {
        firefoxBinary = {
          inherit (self.nix-config-sources.firefox) version;
          url    = https://www.mozilla.org/en-US/firefox/releases;
          script = ''
            grep -o 'data-latest-firefox="[^"]*"' < "$page" |
            grep -o '".*"' > "$out"
          '';
        };

        get_iplayer = {
          inherit (self.nix-config-sources.get_iplayer) version;
          url    = https://github.com/get-iplayer/get_iplayer/releases;
          script = ''
            EXPR='${concatStringsSep "/" [
              ''//a[contains(text(), "Latest release")]''
              ".."
              ".."
              ''/a[contains(@href, "releases/tag")]''
              "text()"
            ]}'
            LATEST=$("${self.xidel}/bin/xidel" - -q -e "$EXPR" < "$page")
            echo "\"$LATEST\"" > "$out"
          '';
        };

        youtube-dl = {
          inherit (self.nix-config-sources.youtube-dl) version;
          url    = https://ytdl-org.github.io/youtube-dl/download.html;
          script = ''
            grep   -o '[^"]*\.tar\.gz' < "$page" |
              head -n1                           |
              grep -o 'youtube-dl-.*\.tar.gz'    |
              cut  -d - -f3                      |
              cut  -d . -f 1-3                   |
              sed  -e 's/\(.*\)/"\1"/g'          > "$out"
          '';
          extra =
            with {
              ours     = self.nix-config-sources.youtube-dl.version;
              packaged = (getAttr self.latest self).youtube-dl.version;
            };
            optional (compareVersions ours packaged < 1) (toJSON {
              inherit ours packaged;
              WARNING = "New youtube-dl is in nixpkgs";
            });
        };
    }
  ;
}
