# Turn files of the form "./local/foo.nix" into packages "foo" using callPackage
self: super:

with builtins;
with super.lib;
with rec {
  mkPkg = name: old:
    with rec {
      func     = import (./local + "/${name}.nix");
      result   = self.newScope { inherit self super; } func {};
      hasTests = isAttrs result         &&
                 hasAttr "pkg"   result &&
                 hasAttr "tests" result;
    };
    {
      overrides = old.overrides // listToAttrs [{
               inherit name;
               value = if hasTests
                          then result.pkg
                          else result;
             }];

      tests = old.tests // (if hasTests
                               then { "${name}" = result.tests; }
                               else {});
    };
};
{
  overrides  = with super.lib; {
    configSrc = ./..;

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

    # Remove flaky, heavyweight SpiderMonkey dependency
    libproxy = super.libproxy.overrideDerivation (old: {
      buildInputs  = filter (x: !(lib.hasPrefix "spidermonkey" x.name))
                            old.buildInputs;
      preConfigure = replaceStrings [ ''"-DWITH_MOZJS=ON"'' ]
                                    [ ""                    ]
                                    old.preConfigure;
    });

    # Useful for getting warbo-* git repositories from a local mirror
    repoSource =
      with {
        env = getEnv "GIT_REPO_DIR";
        dir = /home/chris/Programming/repos;
      };
      if env != ""
         then env
         else if pathExists dir
                 then toString dir
                 else "http://chriswarbo.net/git";

    withLatestCfg = nixpkgs: import nixpkgs {
      overlays = import "${self.latestNixCfg}/overlays.nix";
    };
  };
  tests      = {};
}
