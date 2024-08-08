self: super: {
  overrides = {
    yt-dlp =
      with {
        inherit (self.nix-helpers.pinnedNixpkgs.nixpkgs2111) phantomjs2;
        rev = "abe10131fc235b7cc7af39f833e417f4264c1fdb";
      };
      self.nixpkgsUpstream.yt-dlp.overrideAttrs (_: {
        name = "yt-dlp-${rev}";
        src = super.fetchFromGitHub {
          inherit rev;
          owner = "yt-dlp";
          repo = "yt-dlp";
          sha256 = "sha256-u069kH4DsOLwSC7DrXkS0pOSmaYDHd9EwsH/6FirBZI=";
        };
        postInstall = ''
          ${old.postInstall or ""}
          wrapProgram "$out/bin/yt-dlp" --prefix PATH : "${phantomjs2}/bin"
        '';
      });
  };
  tests = { };
}
