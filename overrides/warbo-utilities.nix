self: super:
with rec {
  inherit (builtins) getAttr hasAttr;

  fetchGitIPFS = super.fetchGitIPFS or
    (import ./fetchGitIPFS.nix self super).overrides.fetchGitIPFS;

  warbo-utilities-src =
    fetchGitIPFS { sha1 = "aadddd763727644dabe8c4feeafcfcdb2c9f9888"; };

  get = name: { ${if hasAttr name super then name else null} = super.${name}; };

  args =
    { inherit fetchGitIPFS; } //
    get "nix-helpers" //
    get "warbo-packages" //
    get "nixpkgs-lib" //
    (if super ? fetchurl then { nixpkgs = super; } else {});
};
{
  overrides.warbo-utilities =
    super.warbo-utilities or (import warbo-utilities-src args);
}
