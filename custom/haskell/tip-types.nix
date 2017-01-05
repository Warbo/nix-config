self: super:

with self;
with builtins;
with rec {
  typesSrc = runCommand "mk-types-src" { inherit tipSrc; } ''
    #!${bash}/bin/bash
    cp -r "$tipSrc/tip-types" "$out"
  '';
};

nixFromCabal typesSrc null
