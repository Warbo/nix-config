self: super:

with builtins;
with self.lib;
rec {
  sanitiseName = str:
    stringAsChars (c: if elem c (lowerChars ++ upperChars)
                         then c
                         else "")
                  str;
}
