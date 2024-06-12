{
  aws-login,
  coreutils,
  writeShellApplication,
}:

writeShellApplication {
  name = "with-aws-creds";
  runtimeInputs = [
    aws-login
    coreutils
  ];
  text = builtins.readFile ./with-aws-creds.sh;
}
