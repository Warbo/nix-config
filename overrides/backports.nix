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
{
  overrides = {
    youtube-dl =
      with rec {
        ourV = "2019.04.24";

        override = self.nixpkgs1903.youtube-dl.overrideDerivation (old: {
          name    = "youtube-dl-${ourV}";
          version = ourV;
          src     = fetchurl {
            url    = "https://yt-dl.org/downloads/${ourV}/youtube-dl-${ourV}.tar.gz";
            sha256 = "1kzz3y2q6798mwn20i69imf48kb04gx3rznfl06hb8qv5zxm9gqz";
          };
        });

        latestPackage = (getAttr self.latest self).youtube-dl;

        needOverride = compareVersions ourV latestPackage.version == 1;

        msg = if needOverride then (x: x) else trace (toJSON {
          overrideVersion = ourV;
          latestPackaged  = latestPackage.version;
          warning = ''
            FIX${""}ME: Our updated youtube-dl override is older than one in
            nixpkgs. We should remove our override and use the packaged one.
          '';
        });
      };
      msg override;
  };
}
