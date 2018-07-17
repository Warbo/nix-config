{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

{
  nix-helpers = fetchgit {
    url    = http://chriswarbo.net/git/nix-helpers.git;
    rev    = "6227a40";
    sha256 = "077kcal167ixwjj41sqrndd5pwvyavs20h826qx3ijl2i02wmwxs";
  };

  warbo-packages = fetchgit {
    url    = http://chriswarbo.net/git/warbo-packages.git;
    rev    = "b934330";
    sha256 = "0gp8fvf4nz0ylqma5q4pxs6580gb694bhwkh3dvh4fy1gmyn2xzz";
  };

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "61edfa6";
    sha256 = "1asj5x30m9ya39fpxvdzgx7m7cjw64jnm1c599l17rcq846yim22";
  };
}
