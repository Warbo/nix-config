self: super: with { inherit (builtins) fetchGit; }; {
  overrides = {
    nix-helpers-src = fetchGit {
      url = "http://chriswarbo.net/git/nix-helpers.git";
      rev = "120a170a3a92ecf08b49d712cf1209c74509d1db";
    };
    warbo-packages-src = fetchGit {
      url = "http://chriswarbo.net/git/warbo-packages.git";
      rev = "faaeedf0b2de5ff07f7d170b79b1f0997b2df71c";
    };
    warbo-utilities-src = fetchGit {
      url = "http://chriswarbo.net/git/warbo-utilities.git";
      rev = "574ee2e07e9ff71837501c9aa6997a7450164a1d";
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
