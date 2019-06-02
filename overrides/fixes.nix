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

    thermald = trace "FIXME: thermald broken on 19.03" super.nixpkgs1803.thermald;
  };

  tests = { inherit (self) libproxy; };
}
