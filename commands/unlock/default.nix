{ python3, writeShellApplication }:

writeShellApplication {
  name = "unlock";
  runtimeInputs = [ (python3.withPackages (p: [ p.secretstorage ])) ];
  text = "exec python3 ${./unlock.py}";
}
