self: super: {
  overrides = {
    yt-dlp =
      with {
        inherit (self.nix-helpers.pinnedNixpkgs.nixpkgs2111) phantomjs2;
      };
      self.nixpkgsUpstream.yt-dlp.overrideAttrs (old: {
        name = "yt-dlp-${rev}";
        src = super.fetchFromGitHub {
          owner = "yt-dlp";
          repo = "yt-dlp";
          rev = "3905f64920ed078d9eeb5640884f5854e01d744d";
          sha256 = "sha256-6zv2NqbUxirMwa6OCzeKXuqLB4sFiYAcy3TYke2jhKc=";
        };
        postInstall = ''
          ${old.postInstall or ""}
          wrapProgram "$out/bin/yt-dlp" --prefix PATH : "${phantomjs2}/bin"
        '';
      });
  };
  tests = { };
}
