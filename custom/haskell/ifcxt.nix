self: super: with self;

with rec {
  new = haskellGit {
    url = "${repoSource}/ifcxt.git";
    ref = "constraints";
  };

  # Forces nix-eval to use non-overriden version of ifcxt
  NIX_EVAL_HASKELL_PKGS = writeScript "ghc7.10-for-nix-eval.nix" ''
    with import <nixpkgs> {};
    haskell.packages.ghc7103 // {
      inherit (origPkgs.haskell.packages.ghc7103) ifcxt;
    }
  '';

  broken = runCommand "runtime-arbitrary-tests"
    (withNix {
      inherit NIX_EVAL_HASKELL_PKGS;
      buildInputs = [ haskellPackages.runtime-arbitrary-tests ];
    })
    ''
      runtime-arbitrary-tests && echo "Pass" > "$out"
    '';
};
withArgsOf new (args:
  haskell.lib.addExtraLibrary (new args) {
    #overrideStillRequired = shouldFail broken;
  })
