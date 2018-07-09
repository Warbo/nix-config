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
      rev    = "bb75beb";
      sha256 = "0cyp3drylrp0dvh4sll5lvi0n511grxfpmka2d5pdy4jxl0803p5";
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
      rev    = "30af50d";
      sha256 = "0v8fr32ivxjmgdgihgrzbsinw642sp8kyqgspaxlqvp4hdmwljx1";
    };
    path = /home/chris/warbo-utilities;
  }
]
