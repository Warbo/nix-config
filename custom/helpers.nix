self: super:

with builtins;
with self.lib;
let helpers = rec {
  sanitiseName = str:
    stringAsChars (c: if elem c (lowerChars ++ upperChars)
                         then c
                         else "")
                  str;
};
in helpers // { inherit helpers; }
