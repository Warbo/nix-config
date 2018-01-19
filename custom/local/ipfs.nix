{ getNixpkgs, stable, super }:

with getNixpkgs {
  rev    = "c44be81";
  sha256 = "1ipsvwd8dflv7k9wagw1yaqcnwfx410bfp7lrvz8cbmj7q8whlaj";
};

if stable
   then pkgs.ipfs
   else super.ipfs
