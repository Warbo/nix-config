self: super:

{
  youtube-dl = self.stdenv.lib.overrideDerivation super.youtube-dl (old: {
    src = self.latestGit { url = "https://github.com/rg3/youtube-dl.git"; };
  });
}
