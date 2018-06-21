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
  bootstrapPkgs = [ "acl" "attr" "bzip2" "coreutils" "xz" "zlib" ];

  pkgs = bootstrapPkgs;
};
{
  pkgs  = genAttrs pkgs (n: getAttr n (getAttr self.version self.customised));
  tests = {};
}
