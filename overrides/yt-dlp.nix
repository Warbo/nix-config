self: super:
with rec {
  repos = (import ../overlays.nix).repos (super // repos) super;

  nix-helpers = self.nix-helpers or repos.nix-helpers;

  nixpkgsUpstream = self.nixpkgsUpstream or
    ((import ../overlays.nix).nixpkgsUpstream
      (super // nixpkgsUpstream) super).nixpkgsUpstream;
};
{
  overrides = {
    yt-dlp =
      with {
        inherit (nix-helpers.pinnedNixpkgs.nixpkgs2111) phantomjs2;
        src = super.fetchFromGitHub {
          owner = "yt-dlp";
          repo = "yt-dlp";
          rev = "3905f64920ed078d9eeb5640884f5854e01d744d";
          sha256 = "sha256-6zv2NqbUxirMwa6OCzeKXuqLB4sFiYAcy3TYke2jhKc=";
        };
      };
      nixpkgsUpstream.yt-dlp.overrideAttrs (old: {
        inherit src;
        name = "yt-dlp-${src.rev}";
        postInstall = ''
          ${old.postInstall or ""}
          wrapProgram "$out/bin/yt-dlp" --prefix PATH : "${phantomjs2}/bin"
        '';
      });
  };
  tests = { };
}
