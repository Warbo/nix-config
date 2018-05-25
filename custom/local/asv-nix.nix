{ callPackage, hasBinary, latestGit, repoSource, withDeps }:

with rec {
  untested = callPackage (latestGit {
    url    = "${repoSource}/asv-nix.git";
    stable = {
      rev    = "d5af74d";
      sha256 = "1jp5a8p5dzh2vb2s9k2wf3j2l9fcm7l47ydqy8wlrjiyqlc4jw7a";
    };
  }) {};

  pkg = withDeps [ (hasBinary untested "asv") ] untested;
};
{
  inherit pkg;
  tests = pkg;
}
