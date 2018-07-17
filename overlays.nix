with builtins;
with rec {
  localOrRemote = name:
    with rec {
      file = "overlay.nix";
      path = locals."${name}" + "/${file}";
    };
    import (if pathExists path
               then path
               else "${remotes."${name}"}/${file}");

  remotes = import ./helpers.nix {};

  locals  = {
    nix-helpers     = /home/chris/Programming/Nix/nix-helpers;
    warbo-packages  = /home/chris/Programming/Nix/warbo-packages;
    warbo-utilities = /home/chris/warbo-utilities;
  };
};
[ (import ./overlay.nix) ] ++ map localOrRemote (attrNames (locals // remotes))
