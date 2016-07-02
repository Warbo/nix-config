self: super:

{

localOnly = builtins.getEnv "NIX_LOCAL_ONLY" == "1";

}
