{ git, writeShellApplication }:

writeShellApplication {
  name = "unlocked";
  runtimeInputs = [ git ];
  text = builtins.readFile ./unlocked.sh;
}
