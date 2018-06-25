{ callPackage, die, hasBinary, latestGit, lib, nix, repoSource, withDeps }:

with builtins;
with rec {
  raw = callPackage (latestGit {
    url    = "${repoSource}/asv-nix.git";
    stable = {
      rev    = "d5af74d";
      sha256 = "1jp5a8p5dzh2vb2s9k2wf3j2l9fcm7l47ydqy8wlrjiyqlc4jw7a";
    };
  }) {};

  inheritNix = lib.overrideDerivation raw (old: {
    name    = "asv-nix-fixme";
    example = lib.overrideDerivation old.example (old:
      with {
        withoutNix = filter (p: !(lib.hasPrefix "nix" p.name))
                            old.buildInputs;
      };
      assert (1 + length withoutNix) == length old.buildInputs || die {
        error      = "Removing Nix from buildInputs didn't remove anything";
        withNix    = map (x: x.name) old.buildInputs;
        withoutNix = map (x: x.name) withoutNix;
      };
      { buildInputs = withoutNix ++ [ nix ]; }
    );
  });

  untested = trace
    ''
      FIXME: Overriding the nix dependency in asv-nix's example test. This is to
      ensure our libuv override (with flaky tests disabled) gets used.
    ''
    inheritNix;

  pkg = withDeps [ (hasBinary untested "asv") ] untested;
};
{
  inherit pkg;
  tests = pkg;
}
