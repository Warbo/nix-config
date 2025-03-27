self: super: {
  overrides = {
    yt-dlp =
      with {
        src = super.fetchFromGitHub rec {
          owner = "yt-dlp";
          repo = "yt-dlp";
          rev = "6eaa574c8217ea9b9c5177fece0714fa622da34c";
          hash = "sha256-TYif7jVXrklMdULTEHYkdAy4MySnOhrJyA4vy2uTSSg=";
        };
      };
      super.yt-dlp.overrideAttrs (old: {
        inherit src;
        name = "yt-dlp-${src.rev}";
      });
  };
  tests = { };
}
