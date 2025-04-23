self: super: {
  overrides.nix =
    with rec {
      inherit (import "${src}") default;

      src = builtins.fetchTree {
        type = "tarball";
        url = "https://github.com/NixOS/nix/archive/d72fc01ffd190a66a0c05c3734473d7a5c2fdb38.tar.gz";
        narHash = "sha256-V24VOap1Hsk1FgSo22themQvIN20pFt6wGcXymMI57Q=";
      };

      warn = if self.nixVersions ? nix_2_27
             then builtins.trace "WARNING: Nix 2.27 backport is obsolete"
             else (x: x);

      fiddled = default // {
        meta = default.meta // {
          inherit (self.nixVersions.latest.meta) platforms;
        };
      };
    };
    warn fiddled;
}
