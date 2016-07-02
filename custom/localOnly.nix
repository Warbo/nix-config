self: super:

{

localOnly = builtins.getEnv "NIX_LOCAL_ONLY" == "1";

onOff = online: offline: if self.localOnly then offline
                                           else  online;

}
