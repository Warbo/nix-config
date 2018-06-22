# These packages are taken straight from whichever nixpkgs set we're overriding,
# and crucially they do no get their dependencies replaced by our overrides. For
# example if one of these packages 'foo' depends on 'bar' and we have an
# override for 'bar' (e.g. in local/), then this 'foo' package will *not* use
# that override.
# This is mostly useful for avoiding dependency overrides for Nix's "bootstrap"
# packages; these are things like 'xz' which Nix itself depends on. Since we
# override *everything* provided by <nixpkgs>, to ensure we're using pinned
# nixpkgs versions, we end up replacing these bootstrap packages, which causes a
# *huge* diff from the normal nixpkgs. This would stop us using binary caches.
self: super:

with builtins;
with super.lib;
with rec {
  # These were found using 'nix-diff' to compare 'nix' against 'nixpkgs1803.nix'
  # and trying to minimise the difference.
  bootstrapPkgs = [
    "acl" "attr" "bash" "bzip2" "coreutils" "gawk" "gnugrep" "gnused" "gzip"
    /*"libiconv"*/ "patchelf" "pcre" /*"perl"*/ "xz" "zlib"
  ];

  # These take a while to build, and can cause cascades requiring other packages
  # to be rebuilt, when we don't actually care about overriding them.
  slowPkgs = [ "gcc" "nix" ];

  all = bootstrapPkgs ++ slowPkgs;
};
{
  pkgs  = genAttrs all (n: getAttr n (getAttr super.version super.customised));
  tests = {};
}
