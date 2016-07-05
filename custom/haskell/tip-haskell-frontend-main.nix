self: super: with self;

let tipSrc = fetchgit {
               url    = https://github.com/tip-org/tools.git;
               rev    = "6ded3a8"; # Version 0.2.2
               sha256 = "1ibf0gd2wig58a20r3jaj3yiqxi981f75fcsss5czwnk9p9yv3vb";
             };
    thfSrc = self.stdenv.mkDerivation {
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
