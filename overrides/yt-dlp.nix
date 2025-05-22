self: super: {
  overrides =
    with rec {
      inherit (import ./nix-helpers.nix (super // overrides) super) overrides;
      nix-helpers = super.nix-helpers or overrides.nix-helpers;
    };
    {
      yt-dlp =
        with rec {
          tree = "bcc63f76e169d360685d4a4ad7c2a5433ba406bf";
          src = nix-helpers.fetchTreeFromGitHub {
            inherit tree;
            owner = "yt-dlp";
            repo = "yt-dlp";
          };
        };
        super.yt-dlp.overrideAttrs (old: {
          inherit src;
          name = "yt-dlp-${tree}";
        });
    };
  tests = { };
}
