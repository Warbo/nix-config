pkgs: rec {
  # Bug https://github.com/NixOS/nixpkgs/issues/7810 causes ghc742Binary to
  # look for libncurses.so.5 which the default ncurses doesn't provide. We use
  # ncursesFix to work around this. The ./local/ncurses directory is just a
  # copy of nixpkgs 41b53577a8f2:pkgs/development/libraries/ncurses

  ncursesFix = pkgs.callPackage ./ncurses {};

  # We *could* override ncurses with ncursesFix at the top level, ie.

  #ncurses = ncursesFix;

  # But we'd rather not, since that would cause most of the OS to be rebuilt.
  # Instead, we only override the ncurses used by ghc742Binary.

  # Since GHC is written in Haskell, it needs to be bootstrapped. As of
  # 2015-05-27 the default haskellPackages is built with ghc7101, ghc7101 is
  # built with ghc784 and ghc784 is built with the pre-built binary
  # ghc742Binary.
  # These packages are defined relative to each other in haskell-packages.nix,
  # rather than going through the top level where we can override them. Hence
  # we must override:
  #
  #  - haskell.compiler.ghc742Binary (to fix the ncurses issue)
  #  - haskell.compiler.ghc784       (to be built by *our* ghc742Binary)
  #  - haskell.compiler.ghc7101      (to be built by *our* ghc784)
  #  - haskell.packages.ghc7101      (to be built by *our* ghc7101)
  #  - haskellPackages               (to be *our* haskell.packages.ghc7101)

  # Define the compilers and packages
  ghc742BinaryC = pkgs.haskell.compiler.ghc742Binary.override {
                    ncurses = ncursesFix;
                  };
  ghc784C  = pkgs.haskell.compiler.ghc784.override  { ghc = ghc742BinaryC; };
  ghc7101C = pkgs.haskell.compiler.ghc7101.override { ghc = ghc784C;       };
  ghc784P  = pkgs.haskell.packages.ghc784.override  { ghc = ghc784C;       };
  ghc7101P = pkgs.haskell.packages.ghc7101.override { ghc = ghc7101C;      };

  # Replace the regular Haskell setup with our modification
  haskell = pkgs.haskell // {
    compiler = pkgs.haskell.compiler // {
      ghc742Binary = ghc742BinaryC;
      ghc784       = ghc784C;
      ghc7101      = ghc7101C;
    };
    packages = {
      ghc784  = ghc784P;
      ghc7101 = ghc7101P;
    };
  };

  # Point the default synonym to our setup
  haskellPackages = haskell.packages.ghc7101;
}
