# Updated get_iplayer
pkgs:

with import <nixpkgs> {};

{
  get_iplayer = stdenv.lib.overrideDerivation pkgs.get_iplayer (oldAttrs : {
    name = "get_iplayer";
    src  = fetchurl {
      url    = ftp://ftp.infradead.org/pub/get_iplayer/get_iplayer-2.94.tar.gz;
      sha256 = "16p0bw879fl8cs6rp37g1hgrcai771z6rcqk2nvm49kk39dx1zi4";
    };
    propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
                              perlPackages.XMLSimple
                              ffmpeg
                            ];
  });
}
