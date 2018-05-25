# Updated get_iplayer
{ buildEnv, fetchurl, ffmpeg, hasBinary, super, perlPackages, stdenv,
  withDeps }:

with rec {
  get_iplayer_real = stdenv.lib.overrideDerivation super.get_iplayer
    (oldAttrs : {
      name = "get_iplayer";
      src  = fetchurl {
        url    = https://github.com/get-iplayer/get_iplayer/archive/v3.05.tar.gz;
        sha256 = "1lk63myf5smm1i9yd9f0ml5cpwj1kqh480y5s1g0mllr4zk8vv5v";
      };
      propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
                                perlPackages.XMLSimple
                                ffmpeg
                              ];
    });

  # Some dependencies seem to be missing, so bundle them in with get_iplayer
  pkg = buildEnv {
    name  = "get_iplayer";
    paths = [ get_iplayer_real ffmpeg perlPackages.XMLSimple ];
  };

  tested = withDeps [ (hasBinary pkg "get_iplayer") ] pkg;
};
{
  pkg   = tested;
  tests = tested;
}
