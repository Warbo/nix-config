{ super }:

builtins.trace "FIXME: Disabling libuv tests"
               (super.libuv.overrideAttrs (old: {
                 doCheck = false;
               }))
