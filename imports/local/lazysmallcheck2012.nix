with import <nixpkgs> {};

{ haskellPackages }:

let altPkgs = haskellPackages.override {
      overrides = self: super: {
        # Requires syb < 0.5
        syb = haskellPackages.syb.override (args: args // {
          mkDerivation = expr: args.mkDerivation (expr // {
            version = "0.4.4";
            sha256  = "11sc9kmfvcn9bfxf227fgmny502z2h9xs3z0m9ak66lk0dw6f406";
          });
        });
      };
    };
in altPkgs.callPackage
  (nixFromCabal (latestGit {
                   url = http://chriswarbo.net/git/lazy-smallcheck-2012.git;
                 }))
  {}
