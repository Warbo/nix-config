{ fetchFromGitHub, hasBinary, haskell, haskellPackages, runCabal2nix,
  withDeps }:

with rec {
  hsPkgs = haskellPackages.override {
    overrides = self: super: {
      brittany = self.callPackage (runCabal2nix {
        url = fetchFromGitHub {
          owner  = "lspitzner";
          repo   = "brittany";
          rev    = "b43ee43";
          sha256 = "0mk46vk8li5a93bi93z1y7qr3r1ij7l0kiripcllkbg86ysdyzy6";
        };
      }) {};

      # Until https://github.com/EduardSergeev/monad-memo/pull/4
      monad-memo = haskell.lib.dontCheck super.monad-memo;
    };
  };

  brittany = hsPkgs.brittany;

  check = hasBinary brittany "brittany";
};

withDeps [ check ] brittany
