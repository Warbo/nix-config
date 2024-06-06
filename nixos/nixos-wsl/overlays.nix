  (self: super: {
    # GitHub don't support 'v3' in their API anymore; this fork uses an
    # appropriate replacement.
    update-nix-fetchgit = super.update-nix-fetchgit.overrideAttrs (old: {
      src = builtins.fetchTarball {
        url = "https://github.com/ja0nz/update-nix-fetchgit/archive/7460aede467fbaf4f3db363102d299232f9684e2.tar.gz";
      };
    });
  })
