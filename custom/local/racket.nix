{ nixpkgs1609, super }:

with builtins;
rec {
  pkg = with (tryEval super.racket);
        if success
           then trace "WARNING: Racket override wasn't needed" value
           else nixpkgs1609.racket;
  tests = pkg;
}
