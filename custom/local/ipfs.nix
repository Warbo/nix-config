self: super:

with rec {
  newpkgs-src = self.fetchFromGitHub {
    owner  = "NixOS";
    repo   = "nixpkgs";
    rev    = "c44be81";
    sha256 = "1ipsvwd8dflv7k9wagw1yaqcnwfx410bfp7lrvz8cbmj7q8whlaj";
  };

  newpkgs = import "${newpkgs-src}" { config = {}; };
};

{
  inherit (newpkgs) ipfs;
}
