# Shortcuts for looking up the latest versions of things. This can be useful for
# taking a particular, hard-coded revision of nix-config (to appease fetchgit),
# and using it to bootstrap the latest version (e.g. via withLatestNixCfg).
self: super:

with builtins;
with super.lib;
{
  overrides = {
    # Whichever nixpkgs version we're using, with the latest nix-config overlay
    latestCfgPkgs = self.withLatestCfg self.path;

    # The latest nixpkgs version which we have the repo for
    latest = fold (x: y: if x == null
                            then y
                            else if y == null
                                 then x
                                 else if compareVersions x y == -1
                                         then y
                                         else x)
                  null
                  (filter (hasPrefix "nixpkgs") (attrNames self.customised));

    # The latest revision of this repo
    latestNixCfg = self.latestGit {
      url    = "${self.repoSource}/nix-config.git";
      stable = { unsafeSkip = true; };
    };

    # A known-good version of nixpkgs to default to, if needed
    stableVersion = "nixpkgs1909";

    # Imports the given nixpkgs repo with the latest version of nix-config
    withLatestCfg = nixpkgs: import nixpkgs {
      overlays = import "${self.latestNixCfg}/overlays.nix";
    };
  };
}
