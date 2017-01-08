{ fetchFromGitHub, stable ? true }:

with rec {
  version = if stable
               then {
                 rev    = "6ded3a8"; # Version 0.2.2
                 sha256 = "1ibf0gd2wig58a20r3jaj3yiqxi981f75fcsss5czwnk9p9yv3vb";
               }
               else {
                 rev    = "51a8ddb";
                 sha256 = "09ngg98yd52vygn3v4mcx20lh99qi06k5xgylnbc07bz7immgyy2";
               };
};

fetchFromGitHub {
  inherit (version) rev sha256;

  owner = "tip-org";
  repo  = "tools";
}
