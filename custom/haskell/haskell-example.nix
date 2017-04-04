self: super: with self;

let example = stdenv.mkDerivation {
                name = "haskell-example-src";
                src  = latestGit { url = "${repoSource}/writing.git"; };
                buildCommand = ''
                  source $stdenv/setup

                  cp -ar "$src/TransferReport/haskell_example" "$out"
                '';
              };
 in nixFromCabal example null
