with builtins;
with rec {
  inherit (import <nixpkgs> { config = {}; overlays = []; }) fetchgit;
  localOrRemote = { args, file ? "overlay.nix", path }:
    import (if pathExists (path + "/${file}")
               then path + "/${file}"
               else "${fetchgit args}/${file}");
};
map localOrRemote [
  {
    args = {
      url    = http://chriswarbo.net/git/nix-helpers.git;
      rev    = "46348ac";
      sha256 = "13wjrli7wv9da4rhcnqh1g8z0nc2x0mq6wli1fmazw9759lky53m";
    };
    path = /home/chris/Programming/Nix/nix-helpers;
  }
  {
    args = {
      url    = http://chriswarbo.net/git/warbo-packages.git;
      rev    = "815f02d";
      sha256 = "0rwilzi7sc0z9cy41ndyi5k5h8p1w73dvgrrn33a4sc7wwjqbxgl";
    };
    path = /home/chris/Programming/Nix/warbo-packages;
  }
  {
    args = {
      url    = http://chriswarbo.net/git/warbo-utilities.git;
      rev    = "a5c3f48";
      sha256 = "10d762iais3xsv1v7x9nyzwvzg7flywygs6fakz6vqqq3ls4jk5c";
    };
    path = /home/chris/warbo-utilities;
  }
]
