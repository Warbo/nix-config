self: super:
with rec {
  inherit (builtins) getAttr hasAttr;

  fetchGitIPFS =
    super.fetchGitIPFS or (import ./fetchGitIPFS.nix self super)
    .overrides.fetchGitIPFS;

  warbo-utilities-src =
    fetchGitIPFS { sha1 = "d4fe476e8793b6e20a7668bb1c73b08be6fb1291"; };

  get = name: { ${if hasAttr name super then name else null} = super.${name}; };

  args =
    {
      inherit fetchGitIPFS;
    }
    // get "nix-helpers"
    // get "warbo-packages"
    // get "nixpkgs-lib"
    // (if self ? path then { nixpkgs = self; } else { });
}; {
  overrides.warbo-utilities = import warbo-utilities-src args;
}
