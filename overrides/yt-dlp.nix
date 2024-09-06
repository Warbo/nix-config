self: super: {
  overrides = {
    yt-dlp =
      with {
        inherit (self.nix-helpers.pinnedNixpkgs.nixpkgs2111) phantomjs2;
        rev = "a065086640e888e8d58c615d52ed2f4f4e4c9d18";
      };
      self.nixpkgsUpstream.yt-dlp.overrideAttrs (_: {
        name = "yt-dlp-${rev}";
        src = super.fetchFromGitHub {
          inherit rev;
          owner = "yt-dlp";
          repo = "yt-dlp";
          sha256 = "sha256-NjsP8XbaLs4RTXDuviN1MEYQ2Xv//P5MPXIym1S4hEw=";
        };
        postInstall = ''
          ${old.postInstall or ""}
          wrapProgram "$out/bin/yt-dlp" --prefix PATH : "${phantomjs2}/bin"
        '';
      });
  };
  tests = { };
}
