with import ./. {};
runCommand "benchmark-env" {
  buildInputs = [ asv-nix ];
} "exit 1"
