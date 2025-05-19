self: super:
with rec {
  nix-helpers = super.nix-helpers or
    (import ./nix-helpers.nix self super).overrides.nix-helpers;

  nixpkgsUnstableSrc = nix-helpers.fetchTreeFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    tree = "4776538b2bf2d0877b579484178a898df1e9cc83";
  };

  nixpkgsUnstable = import nixpkgsUnstableSrc { config = {}; overlays = []; };
};
{
  overrides.ollama = nixpkgsUnstable.ollama.overrideAttrs (old: rec {
    version = "0.6.6";
    src = self.fetchFromGitHub {
      owner = "ollama";
      repo = "ollama";
      rev = "v${version}";
      hash = "sha256-9ZkO+LrS9rOTgOW8chLO3tnbne/+BSxQY+zOsSoE5Zc=";
    };
    patches = [];
  });
}
