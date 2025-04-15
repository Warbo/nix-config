self: super: {
  overrides = {
    yt-dlp =
      with {
        src = super.fetchFromGitHub rec {
          owner = "yt-dlp";
          repo = "yt-dlp";
          rev = "349f36606fa7fb658216334a73ac7825c13503c2";
          hash = "sha256-csw91VbzY9IursMQFGwnlobZI3U6QOBDo31oq+X0ETI=";
        };
      };
      super.yt-dlp.overrideAttrs (old: {
        inherit src;
        name = "yt-dlp-${src.rev}";
      });
  };
  tests = { };
}
