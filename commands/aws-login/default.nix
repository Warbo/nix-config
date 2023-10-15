{ awscli, coreutils, gnused, jq, pass, writeShellApplication }:
writeShellApplication {
  name = "aws-login";
  text = builtins.readFile ./aws-login.sh;
  runtimeInputs = [ coreutils gnused jq pass awscli ];
}
