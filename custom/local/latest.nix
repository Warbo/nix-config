{ customised, lib }:

with builtins;
with lib;
fold (x: y: if x == null
               then y
               else if y == null
                       then x
                       else if compareVersions x y == -1
                               then y
                               else x)
     null
     (filter (hasPrefix "nixpkgs") (attrNames customised))
