self: super:
with builtins;

{ nix-eval }:

let check = self.runCommand "nix-eval-test"
              {
                # Use known-good Haskell version
                NIX_EVAL_HASKELL_PKGS = self.writeScript "haskellPkgs" ''
                  with import <nixpkgs> {};
                  let repo = fetchFromGitHub {
                               owner  = "NixOS";
                               repo   = "nixpkgs";
                               rev    = "16.03";
                               sha256 = "0m2b5ignccc5i5cyydhgcgbyl8bqip4dz32gw0c6761pd4kgw56v";
                             };
                      newPkgs = import repo { config = {}; };
                   in newPkgs.haskellPackages
                '';

                # Required to make Perl and Haskell accept Unicode
                LANG="en_US.UTF-8";
                LOCALE_ARCHIVE="${self.glibcLocales}/lib/locale/locale-archive";

                # Required to make Nix work recursively
                NIX_REMOTE  = "daemon";
                NIX_PATH    = self.lib.concatStringsSep ":"
                                (map ({path, prefix}: prefix + "=" + path)
                                     builtins.nixPath);

                buildInputs = [ (self.haskellPackages.ghcWithPackages (h: [
                                   h.cabal-install
                                   h.nix-eval
                                   h.QuickCheck
                                   h.tasty
                                   h.tasty-quickcheck
                                ]))
                                self.nix
                                self.warbo-utilities ];
              }
              ''
                set -e
                export HOME="$PWD"
                echo "Making mutable copy of '${nix-eval.src}'" 1>&2

                cp -r "${nix-eval.src}" ./nix-eval
                chmod +w -R ./nix-eval
                cd ./nix-eval

                # Work around Haskell silliness
                export LANG="en_US.UTF-8"

                echo "Configuring" 1>&2
                cabal configure --enable-tests

                echo "Testing" 1>&2
                ./test.sh

                touch "$out"
              '';
 in check
