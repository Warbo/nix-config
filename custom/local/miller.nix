{ autoconf, automake, fetchFromGitHub, flex, libtool, stdenv }:

stdenv.mkDerivation {
  name        = "miller";
  buildInputs = [ autoconf automake flex libtool ];
  preConfigure = ''
    autoreconf -fiv
  '';
  src         = fetchFromGitHub {
    owner  = "johnkerl";
    repo   = "miller";
    rev    = "a3a2458";
    sha256 = "106bzyd564km923y26llxwzgmkys5h47mjp8dwvzc53phksns0wb";
  };
}
