# Use latestGit as src for a derivation, then store the commit ID the derivation
{ url, ref ? "HEAD", srcToPkg ? null, resultComposes ? false }:
with builtins;
assert srcToPkg == null || isFunction srcToPkg;
assert isString url;
assert isString ref;
assert isBool resultComposes;
assert resultComposes -> isFunction srcToPkg;

let pkgs    = import <nixpkgs> {};
    source  = pkgs.latestGit { inherit url ref; };
    result  = srcToPkg source;
    hUrl    = builtins.hashString "sha256" url;
    hRef    = builtins.hashString "sha256" ref;
    rev     = source.rev;
in

assert isAttrs source;
assert hasAttr "rev" source;
assert isAttrs result || isFunction result;
assert resultComposes -> isFunction result;

let cacheRev = p:
      assert isAttrs p;
      pkgs.lib.overrideDerivation p (old: {
        setupHook = pkgs.substituteAll {
          src = ./nixGitRefs.sh;
          key = "${hUrl}_${hRef}";
          val = rev;
        };
      });
    drv = if isFunction result
             then if resultComposes
                     then result cacheRev
                     else args: cacheRev (result args)
             else cacheRev result;
in

assert isFunction result -> isFunction drv;
assert isAttrs    result -> isAttrs    drv;

drv
