{ mergerfs, writeShellApplication }:

writeShellApplication {
  name = "overlay-nix-store";
  runtimeInputs = [ mergerfs ];
  text = builtins.readFile ./overlay-nix-store.sh;
}
