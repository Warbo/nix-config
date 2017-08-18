# Backport gx, if not available
{ getNixpkgs, super }:

with {
  fixed = getNixpkgs {
    rev    = "ff04adf";
    sha256 = "1954x805v27f3qzqzm2zw34j3z40dlxcb9g08xy0yrifp06igwnl";
  };
};
super.gx or fixed.pkgs.gx
