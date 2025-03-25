self: super: {
  overrides = {
    yt-dlp =
      with {
        src = super.fetchFromGitHub {
          owner = "yt-dlp";
          repo = "yt-dlp";
          rev = "336b33e72fe0105a33c40c8e5afdff720e17afdb";
          sha256 = "sha256-rL8jhTD+nMjSuCvt//ZXQvqDcGsHkGUJUUUOqrznufg=";
        };
      };
      super.yt-dlp.overrideAttrs (old: {
        inherit src;
        name = "yt-dlp-${src.rev}";
      });
  };
  tests = { };
}
