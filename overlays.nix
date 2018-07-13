with builtins;
with rec {
  inherit (import <nixpkgs> { config = {}; overlays = []; }) fetchgit;
  localOrRemote = { args, file ? "overlay.nix", path }:
    import (if pathExists (path + "/${file}")
               then path + "/${file}"
               else "${fetchgit args}/${file}");
};
[ (import ./overlay.nix) ] ++ map localOrRemote [
  {
    args = {
      url    = http://chriswarbo.net/git/nix-helpers.git;
      rev    = "96a2fa3";
      sha256 = "0j5xxgjbyjsj9ayj3q7b95s7gzmmahwlj27nvbmdjyrxk3dn7gxz";
    };
    path = /home/chris/Programming/Nix/nix-helpers;
  }
  {
    args = {
      url    = http://chriswarbo.net/git/warbo-packages.git;
      rev    = "b5cf3f2";
      sha256 = "1z21h3r0j0w51mnwafvha86vi2dsv2grwp667ch5q4nvazf6n1sn";
    };
    path = /home/chris/Programming/Nix/warbo-packages;
  }
  {
    args = {
      url    = http://chriswarbo.net/git/warbo-utilities.git;
      rev    = "825659d";
      sha256 = "1p9d6lgvzp19g23fsi2pd5lk856xs2xgpfr0gdvxnjwawbrzqad3";
    };
    path = /home/chris/warbo-utilities;
  }
]
