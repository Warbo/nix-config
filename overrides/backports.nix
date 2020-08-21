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
  inherit (builtins) compareVersions fetchurl foldl' getAttr toJSON;
  inherit (super.lib) concatStringsSep makeOverridable optional;
};
{
  overrides = {
    inherit (import self.sources.niv {}) niv;

    firefoxBinary = self.makeFirefoxBinary self.sources.firefox;

    get_iplayer =
      with rec {
        src = self.sources.get_iplayer;

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
        src = self.sources.youtube-dl;

        override = super.youtube-dl.overrideDerivation (old: {
          inherit (src) version;
          name = "youtube-dl-${src.version}";
          src  = src.outPath;
        });
      };
      foldl' (x: msg: trace msg x) override self.nix-config-checks.youtube-dl;
  };

  checks = {
    firefoxBinary =
      with {
        latest = import (self.runCommand "latest-firefox-version.nix"
          {
            page = fetchurl https://www.mozilla.org/en-US/firefox/releases;
          }
          ''
            grep -o 'data-latest-firefox="[^"]*"' < "$page" |
            grep -o '".*"' > "$out"
          '');

        version = self.sources.firefox.version;
      };
      optional
        (self.onlineCheck && compareVersions version latest == -1)
        (toJSON {
          inherit latest version;
          WARNING = "Newer Firefox is out";
        });

    get_iplayer =
      with rec {
        src = self.sources.get_iplayer;

        latestVersion = import (self.runCommand "latest-get_iplayer.nix"
          {
            buildInputs = [ self.xidel ];
            expr        = concatStringsSep "/" [
              ''//a[contains(text(), "Latest release")]''
              ".."
              ".."
              ''/a[contains(@href, "releases/tag")]''
              "text()"
            ];

            page = fetchurl https://github.com/get-iplayer/get_iplayer/releases;
          }
          ''
            LATEST=$(xidel - -q -e "$expr" < "$page")
            echo "\"$LATEST\"" > "$out"
          '');
      };
      optional
        (self.onlineCheck && compareVersions src.version latestVersion == -1)
        (toJSON {
          inherit latestVersion;
          inherit (src) version;
          WARNING = "Newer get_iplayer available";
        });

    youtube-dl =
      with rec {
        ourVersion = self.sources.youtube-dl.version;

        latestPackage = (getAttr self.latest self).youtube-dl;

        latestRelease = import (self.runCommand "youtube-dl-release.nix"
          { page = fetchurl https://ytdl-org.github.io/youtube-dl/download.html; }
          ''
            grep   -o '[^"]*\.tar\.gz' < "$page" |
              head -n1                           |
              grep -o 'youtube-dl-.*\.tar.gz'    |
              cut  -d - -f3                      |
              cut  -d . -f 1-3                   |
              sed  -e 's/\(.*\)/"\1"/g'          > "$out"
          '');

        warnIf = version: pred: msgBits:
          if self.onlineCheck
             then if pred (compareVersions ourVersion version)
                     then []
                     else [ (toJSON {
                       inherit latestRelease;
                       overrideVersion = ourVersion;
                       latestPackaged  = latestPackage.version;
                       warning         = concatStringsSep " " msgBits;
                     }) ]
             else trace "Skipping youtube-dl check" [];
      };
      warnIf latestPackage.version (x: x == 1) [
        "FIX${""}ME: Our updated youtube-dl override is older than one in"
        "nixpkgs. We should remove our override and use the upstream version."
      ] ++
      warnIf latestRelease (x: x > -1) [
        "Our youtube-dl override is out of date. If it doesn't work, YouTube"
        "might have changed their API, which the update might fix."
      ];
  };
}
