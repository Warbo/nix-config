self: super:

with {
  newpkgs = self.fetchFromGitHub {
    owner  = "NixOS";
    repo   = "nixpkgs";
    rev    = "123dd9f";
    sha256 = "18qa6d7ms7nj90fqhz4gqfrb8qhq0q9s381n1zgbspdbhvn9lms9";
  };
};
{
  inherit (import "${newpkgs}" { config = {}; })
    ipfs;
}
