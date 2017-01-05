self: super: with self;

let thfSrc = self.stdenv.mkDerivation {
               name = "thf-src";
               src  = tipSrc;
               buildCommand = ''
                 source $stdenv/setup

                 D="$src/tip-haskell-frontend"
                 [[ -d "$D" ]] || {
                   echo "Couldn't find '$D'" 1>&2
                   find . 1>&2
                   env 1>&2
                   exit 1
                 }
                 cp -ar "$D" "$out"
               '';
             };
 in nixFromCabal thfSrc null
