self: super:

with {
  newpkgs = self.fetchFromGitHub {
    owner  = "NixOS";
    repo   = "nixpkgs";
    rev    = "aa429e6";
    sha256 = "1y7j59zg2zhmqqk9srh8qmi69ar2bidir4bjyhy0h0370kfvnkrg";
  };
};
{
  inherit (import "${newpkgs}" { config = {}; }) ipfs;
}
