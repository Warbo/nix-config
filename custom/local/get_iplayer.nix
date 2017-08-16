# Updated get_iplayer

{ buildEnv, fetchurl, ffmpeg, origPkgs, perlPackages, stdenv }:

with {
  get_iplayer_real = stdenv.lib.overrideDerivation origPkgs.get_iplayer
    (oldAttrs : {
      name = "get_iplayer";
      src  = fetchurl {
        url    = https://github.com/get-iplayer/get_iplayer/archive/v2.99.tar.gz;
        sha256 = "1kvbs9d13qhnd3dzx36a699r6aqwjsg4yprjj6fwa7hmqsxaab8q";
      };
      propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
                                perlPackages.XMLSimple
                                ffmpeg
                              ];
    });
};

# Some dependencies seem to be missing, so bundle them in with get_iplayer
buildEnv {
  name  = "get_iplayer";
  paths = [ get_iplayer_real ffmpeg perlPackages.XMLSimple ];
}
