self: super: with self;

self.runCabal2nix { url = "cabal://weigh-0.0.3"; }
