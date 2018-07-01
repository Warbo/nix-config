# Shortcuts for looking up the latest versions of things. This can be useful for
# taking a particular, hard-coded revision of nix-config (to appease fetchgit),
# and using it to bootstrap the latest version (e.g. via withLatestNixCfg).
self: super:

with builtins;
with super.lib;
{
  overrides = {
    latestCfgPkgs = self.withLatestCfg self.repo;

    latest = fold (x: y: if x == null
                            then y
                            else if y == null
                                 then x
                                 else if compareVersions x y == -1
                                         then y
                                         else x)
                  null
                  (filter (hasPrefix "nixpkgs") (attrNames self.customised));

    latestNixCfg = self.latestGit {
      url    = "${self.repoSource}/nix-config.git";
      stable = { unsafeSkip = true; };
    };

    withLatestCfg = nixpkgs: import nixpkgs {
      overlays = import "${self.latestNixCfg}/overlays.nix";
    };
  };

  tests = {};
}
