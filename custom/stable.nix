# Stable nixpkgs
self: super:

with builtins;
with {
  getNixpkgs = { rev, sha256 }:
    rec {
      # Explicitly pass an empty config, to avoid loading ~/.nixpkgs/config.nix
      # and causing an infinite loop
      pkgs = import repo { config = {}; };

      repo = super.fetchFromGitHub {
        inherit rev sha256;
        owner = "NixOS";
        repo  = "nixpkgs";
      };
    };

  version = args:
    with {
      name   = replaceStrings ["."] [""] args.rev;
      result = getNixpkgs args;
    };
    {
      "nixpkgs${name}" = result.pkgs;
      "repo${name}"    = result.repo;
    };
};

foldl' (x: y: x // y) {} [
  (version {
    rev    = "16.03";
    sha256 = "0m2b5ignccc5i5cyydhgcgbyl8bqip4dz32gw0c6761pd4kgw56v";
  })

  (version {
    rev    = "16.09";
    sha256 = "0m2b5ignccc5i5cyydhgcgbyl8bqip4dz32gw0c6761pd4kgw56v";
  })

  (version {
    rev    = "17.03";
    sha256 = "1fw9ryrz1qzbaxnjqqf91yxk1pb9hgci0z0pzw53f675almmv9q2";
  })

  {
    # "Blessed" versions
    stableRepo = self.repo1603;
    stable     = self.nixpkgs1603;

    # Unmodified package set
    origPkgs = super;

    # Allow other versions
    inherit getNixpkgs;
  }
]
