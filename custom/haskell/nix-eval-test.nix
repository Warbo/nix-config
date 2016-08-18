self: super:
with builtins;

{ nix-eval }:

let check = self.runCommand "nix-eval-test"
              {
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

                echo "passed" > "$out"
              '';
 in check
