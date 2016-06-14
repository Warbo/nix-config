with import <nixpkgs> {};

let tipSrc = fetchgit {
               url    = https://github.com/tip-org/tools.git;
               rev    = "6ded3a8"; # Version 0.2.2
               sha256 = "1ibf0gd2wig58a20r3jaj3yiqxi981f75fcsss5czwnk9p9yv3vb";
             };
 in nixFromCabal "${tipSrc}/tip-haskell-frontend" null
