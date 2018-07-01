# Turn files of the form "./local/foo.nix" into packages "foo" using callPackage
self: super:

with builtins;
with super.lib;
{
  overrides = {
    # Remove flaky, heavyweight SpiderMonkey dependency
    libproxy = super.libproxy.overrideDerivation (old: {
      buildInputs  = filter (x: !(lib.hasPrefix "spidermonkey" x.name))
                            old.buildInputs;
      preConfigure = replaceStrings [ ''"-DWITH_MOZJS=ON"'' ]
                                    [ ""                    ]
                                    old.preConfigure;
    });
  };

  tests = {};
}
