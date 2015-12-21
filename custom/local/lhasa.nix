{ stdenv, fetchFromGitHub, autoconf, automake, libtool }:

stdenv.mkDerivation {
  name = "lhasa";
  src = fetchFromGitHub {
    owner = "fragglet";
    repo = "lhasa";
    rev = "2a6cc7f";
    sha256 = "1b6y8rmidzcx6p9j0cn7615nljxn7smaddiqh8sm9a28mhydipsk";
  };
  buildInputs = [ autoconf automake libtool ];
  installFlags = "prefix=$(out)";
  configurePhase = ''
    ./autogen.sh
  '';
}
