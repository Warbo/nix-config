self: super:

with self;
with builtins;
with rec {
  typesSrc = runCommand "mk-types-src" { inherit unstableTipSrc; } ''
    #!${bash}/bin/bash
    cp -r "$unstableTipSrc/tip-types" "$out"
  '';
};

nixFromCabal typesSrc null
