with import ./nix;
runCommand "config-env" { buildInputs = [ asv-nix ]; } "exit 1"
