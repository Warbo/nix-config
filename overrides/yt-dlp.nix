self: super: {
  overrides = {
    yt-dlp = self.nixpkgsUpstream.yt-dlp.overrideAttrs (_: {
      name = "yt-dlp-custom";
      src = super.fetchFromGitHub {
        owner = "yt-dlp";
        repo = "yt-dlp";
        rev = "abe10131fc235b7cc7af39f833e417f4264c1fdb";
        sha256 = "sha256-u069kH4DsOLwSC7DrXkS0pOSmaYDHd9EwsH/6FirBZI=";
      };
    });
  };
  tests = { };
}
