{ bubblewrap, writeShellApplication }:
writeShellApplication {
  name = "with-nix-store";
  runtimeInputs = [ bubblewrap ];
  text = builtins.readFile ./with-nix-store.sh;
}
