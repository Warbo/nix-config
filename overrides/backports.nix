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

with builtins;
with super.lib;
{
  overrides = {
    get_iplayer =
      with rec {
        # Update this as needed
        tag    = "v3.25";
        sha256 = "0qvx5f1n4kqazm0sykagv1d83v31hxy38vaf4a4n4ka92al7iqia";
        src    = versionTest self.fetchurl {
          inherit sha256;
          url =
            "https://github.com/get-iplayer/get_iplayer/archive/${tag}.tar.gz";
        };

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

        versionTest = if self.onlineCheck &&
                         compareVersions tag latestVersion == -1
                         then trace (toJSON {
                           inherit latestVersion tag;
                           WARNING = "Newer get_iplayer available";
                         })
                         else (x: x);

        get_iplayer_real = { ffmpeg, get_iplayer, perlPackages }:
          self.stdenv.lib.overrideDerivation get_iplayer
            (oldAttrs : {
              inherit src;
              name                  = "get_iplayer-${tag}";
              propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
                perlPackages.LWPProtocolHttps
                perlPackages.XMLSimple
                ffmpeg
              ];
            });

        mkPkg = { ffmpeg, get_iplayer, perlPackages }: self.buildEnv {
          name  = "get_iplayer";
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
        ourV   = "2020.01.24";
        sha256 = "1zrnbjnwv315f9a83lk5c0gl4ianvp6q2kinxvqlv604sabcq78b";

        override = super.youtube-dl.overrideDerivation (old: {
          name    = "youtube-dl-${ourV}";
          version = ourV;
          src     = fetchurl {
            inherit sha256;
            url    = concatStrings [
              "https://yt-dl.org/downloads/" ourV "/youtube-dl-" ourV ".tar.gz"
            ];
          };
        });

        latestPackage = (getAttr self.latest self).youtube-dl;

        latestRelease = import (self.runCommand "youtube-dl-release.nix"
          {
            page = fetchurl https://ytdl-org.github.io/youtube-dl/download.html;
          }
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
             then if pred (compareVersions ourV version)
                     then (x: x)
                     else trace (toJSON {
                       inherit latestRelease;
                       overrideVersion = ourV;
                       latestPackaged  = latestPackage.version;
                       warning         = concatStringsSep " " msgBits;
                     })
             else trace "Skipping youtube-dl check" (x: x);

        needOverride = warnIf latestPackage.version (x: x == 1) [
          "FIX${""}ME: Our updated youtube-dl override is older than one in"
          "nixpkgs. We should remove our override and use the upstream version."
        ];

        needUpdate   = warnIf latestRelease (x: x > -1) [
          "Our youtube-dl override is out of date. If it doesn't work, YouTube"
          "might have changed their API, which the update might fix."
        ];
      };
      needOverride (needUpdate override);
  };

  tests = {};
}
