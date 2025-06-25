self: super:
with rec {
  inherit (builtins) getAttr hasAttr;

  fetchGitIPFS = super.fetchGitIPFS or (import ./fetchGitIPFS.nix self super).overrides.fetchGitIPFS;

  warbo-utilities-src = fetchGitIPFS {
    sha1 = "d90ad16c8c74a4126293b71bceb7cc2afbb7dd18";
  };

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
