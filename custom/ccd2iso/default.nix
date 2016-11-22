{ pkgs ? import <nixpkgs> {} }:

with pkgs;

stdenv.mkDerivation {
  name = "ccd2iso";
  src  = ./ccd2iso-0.3.tar.gz;
}