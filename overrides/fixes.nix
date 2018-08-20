# Override broken or non-optimal packages from <nixpkgs> and elsewhere
self: super:

with builtins;
with super.lib;
{
  overrides = {
    # Remove flaky, heavyweight SpiderMonkey dependency
    libproxy = super.libproxy.overrideDerivation (old: {
      buildInputs  = filter (x: !(hasPrefix "spidermonkey" x.name))
                            old.buildInputs;
      preConfigure = replaceStrings [ ''"-DWITH_MOZJS=ON"'' ]
                                    [ ""                    ]
                                    old.preConfigure;
    });
  };

  tests = { inherit (self) libproxy; };
}
