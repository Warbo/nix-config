self: super: with { inherit (builtins) fetchGit; }; {
  overrides = {
    nix-helpers-src = fetchGit {
      url = "http://chriswarbo.net/git/nix-helpers.git";
      rev = "bda41ce6316ac77cd963adf5b95cc7cf095242d0";
    };
    warbo-packages-src = fetchGit {
      url = "http://chriswarbo.net/git/warbo-packages.git";
      rev = "fb802ff3e4209b810a75f240af287319782c32f7";
    };
    warbo-utilities-src = fetchGit {
      url = "http://chriswarbo.net/git/warbo-utilities.git";
      rev = "b0f03a662ef195ed94df41a44ff4c60ec44dc663";
    };

    nix-helpers = import self.nix-helpers-src {
      # nix-helpers takes nixpkgs as an argument, defaulting to its own pinned
      # nixpkgsLatest (whose definition doesn't refer to the given nixpkgs, and
      # hence avoids infinite recursion).
      # We prefer to use the nixpkgs we're overlaying instead, but that might be
      # empty if we're bootstrapping; in those situations we fall back to the
      # nixpkgsLatest default.
      # TODO: Would be nice to use self instead of super; but that relies on our
      # attribute names being determined without referencing nix-helpers.
      nixpkgs = if super ? newScope then super else self.nix-helpers.nixpkgsLatest;
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