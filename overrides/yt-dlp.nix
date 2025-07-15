self: super: {
  overrides =
    with rec {
      inherit (import ./nix-helpers.nix (super // overrides) super) overrides;
      nix-helpers = super.nix-helpers or overrides.nix-helpers;
    }; {
      yt-dlp =
        with rec {
          tree = "497d3e58b206ba02c662aa9ce097dd8dd1832793";
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
