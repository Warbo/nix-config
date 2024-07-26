self: super: {
  overrides = {
    yt-dlp = self.nixpkgsUpstream.yt-dlp.overrideAttrs (_: {
      src = super.fetchFromGitHub {
        owner = "yt-dlp";
        repo = "yt-dlp";
        rev = "6b1e430d8e4af56cd4fcb8bdc00fca9b79356464";
        sha256 = "sha256-GDCFKZxFsfCfBT1it3vnIcLxRcgOQM2JK23ZwLVYEYU=";
      };
    });
  };
  tests = { };
}
