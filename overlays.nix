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
      rev    = "66f9a00";
      sha256 = "0f84hyqslzb56gwc8yrrn8s95nvdfqn0hf6c9i3cng3bsz3yk53v";
    };
    path = /home/chris/Programming/Nix/nix-helpers;
  }
  {
    args = {
      url    = http://chriswarbo.net/git/warbo-packages.git;
      rev    = "c2ea27d";
      sha256 = "04aif1s3cxk27nybsxp571fmvswy5vbw0prq67y108sb49mm3288";
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
