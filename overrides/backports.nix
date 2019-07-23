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
    youtube-dl =
      with rec {
        ourV = "2019.07.16";

        override = super.youtube-dl.overrideDerivation (old: {
          name    = "youtube-dl-${ourV}";
          version = ourV;
          src     = fetchurl {
            sha256 = "06qd6z9swx8aw9v7vi85q44hmzxgy8wx18a9ljfhx7l7wjpm99ky";
            url    = concatStrings [
              "https://yt-dl.org/downloads/" ourV "/youtube-dl-" ourV ".tar.gz"
            ];
          };
        });

        latestPackage = (getAttr self.latest self).youtube-dl;

        latestRelease = import (self.runCommand "youtube-dl-release.nix"
          {
            __noChroot    = true;
            cacheBuster   = toString currentTime;
            buildInputs   = [ self.wget ];
            url           = "";
            SSL_CERT_FILE = "${self.cacert}/etc/ssl/certs/ca-bundle.crt";
          }
          ''
            wget -O- 'https://ytdl-org.github.io/youtube-dl/download.html' |
              grep -o '[^"]*\.tar\.gz'                                     |
              head -n1                                                     |
              grep -o 'youtube-dl-.*\.tar.gz'                              |
              cut -d - -f3                                                 |
              cut -d . -f 1-3                                              |
              sed -e 's/\(.*\)/"\1"/g'                              > "$out"
              #|| echo "1" > "$out"
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
