{ clang, fetchFromGitHub, SDL2, SDL_mixer, stdenv }:

stdenv.mkDerivation {
  name = "openfodder";
  src  = fetchFromGitHub {
    owner  = "OpenFodder";
    repo   = "openfodder";
    rev    = "98ba8df";
    sha256 = "02a5kb0s89accal726myr3kd2wbh6rkahflxpsccs0r7ka2zqcsr";
  };
  buildInputs = [ clang SDL2 SDL_mixer ];
}
