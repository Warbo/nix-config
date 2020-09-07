self: super: {
  overrides = {
    # Take nix-helper's Niv version
    niv = self.pinnedNiv;
  };
}
