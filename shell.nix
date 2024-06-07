with import ./nix;
runCommand "config-env" {
  buildInputs = [
    asv-nix
    niv
  ];
} "exit 1"
