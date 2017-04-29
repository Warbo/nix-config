# Updated get_iplayer
self: super:

with self;

{
  get_iplayer = stdenv.lib.overrideDerivation super.get_iplayer (oldAttrs : {
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
}
