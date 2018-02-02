{ fetchurl, self }:

with {
  commit = "17c3599ee384f41091312955d6af8fb6da9efb97";
  path   = "pkgs/misc/themes/clearlooks-phenix/default.nix";
};
self.callPackage (fetchurl {
  url    = "https://github.com/NixOS/nixpkgs/raw/${commit}/${path}";
  sha256 = "11wy2zv0mc7bx4qhs4764nkq2qkzjad4f9nm0yd64j18hrq7qy3w";
}) {}
