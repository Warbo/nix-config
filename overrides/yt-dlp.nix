self: super: {
  overrides = {
    yt-dlp =
      with {
        src = super.fetchFromGitHub {
          owner = "yt-dlp";
          repo = "yt-dlp";
          rev = "3905f64920ed078d9eeb5640884f5854e01d744d";
          sha256 = "sha256-6zv2NqbUxirMwa6OCzeKXuqLB4sFiYAcy3TYke2jhKc=";
        };
      };
      super.yt-dlp.overrideAttrs (old: {
        inherit src;
        name = "yt-dlp-${src.rev}";
      });
  };
  tests = { };
}
