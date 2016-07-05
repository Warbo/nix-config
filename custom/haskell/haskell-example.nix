self: super: with self;

let remote = latestGit {
               url = http://chriswarbo.net/git/writing.git;
             };
    online = stdenv.mkDerivation {
               name = "haskell-example-src";
               src  = remote;
               buildCommand = ''
                 source $stdenv/setup

                 cp -ar "$src/TransferReport/haskell_example" "$out"
               '';
             };
    local  = "/home/chris/Writing/TransferReport/haskell_example";
    src    = onOff online local;
 in nixFromCabal src null
