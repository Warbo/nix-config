with import <nixpkgs> {};
with {
  src = fetchFromGitHub {
    owner  = "NixOS";
    repo   = "nixpkgs";
    rev    = "ff04adf";
    sha256 = "1954x805v27f3qzqzm2zw34j3z40dlxcb9g08xy0yrifp06igwnl";
  };
};
import "${src}/pkgs/build-support/fetchgx"
