# Remove flaky, heavyweight SpiderMonkey dependency
{ lib, super }:

with builtins;
super.libproxy.overrideDerivation (old: {
  buildInputs  = filter (x: !(lib.hasPrefix "spidermonkey" x.name))
                        old.buildInputs;
  preConfigure = replaceStrings [ ''"-DWITH_MOZJS=ON"'' ]
                                [ ""                    ]
                                old.preConfigure;
})
