{ fetchFromGitHub, stdenv, xorg }:

stdenv.mkDerivation {
  name = "space2ctrl";
  src  = fetchFromGitHub {
    owner  = "r0adrunner";
    repo   = "Space2Ctrl";
    rev    = "8f7c97a";
    sha256 = "1kkbrxdqrmrpynnb18xnjm6gbr1mw2851abcjlv0c15d5calfcw7";
  };
  buildInputs = with xorg; [
    inputproto libX11 libXext libXi libXtst recordproto xinput
  ];
  makeFlags = [ "PREFIX=$(out)" ];
}
