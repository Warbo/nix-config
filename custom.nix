# pkgs is the nixpkgs we're overriding: use it, but don't put it in the result.
# imports contains everything from ./imports: use it and put it in the result.
# imports.local contains everything from ./imports/local: use it and put it in
# the result.
pkgs: imports:

let local = imports.local pkgs;
 in with local; with pkgs; with imports;

imports // local // rec {}
