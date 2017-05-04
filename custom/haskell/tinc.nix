# This is a little complicated...
self: super:
with builtins;
with self;
with lib;
with rec {
  # The tinc repo contains the Haskell, as well as Nix expressions
  src = latestGit { url = https://github.com/sol/tinc.git; };

  # default.nix is too clever, trying to guess which Haskell package set to use,
  # etc. so we use package.nix instead, which looks like raw cabal2nix output.
  func = import "${src}/package.nix";

  # We get the following test failure when building as-is:
  #
  # test/Tinc/AddSourceSpec.hs:102:
  #   1) Tinc.AddSource.parseAddSourceDependencies, when package.yaml can not be
  #      parsed, throws an exception predicate failed on expected exception:
  #      ErrorCall (package.yaml: Error in $['ghc-options']: failed to parse
  #      field ghc-options: expected String, encountered Number)
  #
  # To avoid this, we use dontCheck. That requires a couple of things:
  #  a) We need to 'inner compose' dontCheck with func, so we're given all of
  #     tinc's required arguments when called with callPackage.
  #  b) Since dontCheck uses '.override', we can't just call func as a function,
  #     we need to call it with callPackage. Hence we add callPackage to our
  #     argument list, and remove it from the args we give to func.
  funcArgs           = functionArgs func;
  nonDefaultArgs     = filter (n: !funcArgs."${n}") (attrNames funcArgs);
  withoutCallPackage = filterAttrs (n: _: n != "callPackage");
};

withArgs (nonDefaultArgs ++ [ "callPackage" ])
         (args: haskell.lib.dontCheck
                  (args.callPackage func (withoutCallPackage args)))
