{ autoconf, automake, fetchFromGitHub, hasBinary, libXtst, libX11, libXi,
  libXext, libXinerama, pkgconfig, stdenv, withDeps, xextproto, xlibsWrapper }:

with rec {
  pkg = stdenv.mkDerivation {
    name = "x2x";
    src  = fetchFromGitHub {
      repo   = "x2x";
      owner  = "dottedmag";
      rev    = "89deb1";
      sha256 = "1gcvsfkkf1xhmiv1x9vxgynicw78mvrxiz6a3mgzgyf8b6860d7r";
    };

    buildInputs = [ xlibsWrapper autoconf automake pkgconfig libX11 xextproto
                    libXtst libXi libXext libXinerama ];

    configurePhase = ''
      ./bootstrap.sh
      ./configure --prefix="$out"
    '';
  };

  tested = withDeps [ (hasBinary pkg "x2x") ] pkg;
};
{
  pkg   =   tested;
  tests = [ tested ];
}
