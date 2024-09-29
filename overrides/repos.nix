self: super: with { inherit (builtins) fetchGit; }; {
  overrides = {
    nix-helpers-src = fetchGit {
      url = "http://chriswarbo.net/git/nix-helpers.git";
      rev = "bda41ce6316ac77cd963adf5b95cc7cf095242d0";
    };
    warbo-packages-src = fetchGit {
      url = "http://chriswarbo.net/git/warbo-packages.git";
      rev = "284fe48dfb9934e611a4d516f68bfcd545dfdcb4";
    };
    warbo-utilities-src = fetchGit {
      url = "http://chriswarbo.net/git/warbo-utilities.git";
      rev = "9ba312ab9c1a8377cc384721f306404ccb1d4d8b";
    };

    nix-helpers = import self.nix-helpers-src {
      # Use the nixpkgs set we're overlaying instead of its pinned default
      nixpkgs = super; # TODO: Use self
    };

    warbo-packages = import self.warbo-packages-src {
      # Take nix-helpers from self, to allow subsequent overrides. Note that
      # warbo-packages inherits nixpkgs from nix-helpers, so we don't need to
      # pass super along directly.
      inherit (self) nix-helpers;
    };

    warbo-utilities = import self.warbo-utilities-src {
      # Pick warbo-packages in the same way we chose a nix-helpers above.
      # The nix-helpers will get inherited, as will nixpkgs.
      inherit (self) warbo-packages;
    };
  };
}
