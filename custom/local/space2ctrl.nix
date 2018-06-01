{ fetchFromGitHub, replace, stdenv, xorg }:

stdenv.mkDerivation {
  name = "space2ctrl";
  src  = fetchFromGitHub {
    owner  = "r0adrunner";
    repo   = "Space2Ctrl";
    rev    = "8f7c97a";
    sha256 = "1kkbrxdqrmrpynnb18xnjm6gbr1mw2851abcjlv0c15d5calfcw7";
  };
  buildInputs = with xorg; [
    inputproto libX11 libXext libXi libXtst recordproto replace xinput
  ];

  # Force 'make install' to use $out
  makeFlags = [ "PREFIX=$(out)" ];

  # Avoid triggering a keypress event on startup by commenting out that code
  pre1  = "// TODO: document why the following event is needed";
  post1 = "/*";
  pre2  = "if (!XRecordEnableContext";
  post2 = "*/ if (!XRecordEnableContext";

  preBuild  = ''
    replace "$pre1" "$post1" -- Space2Ctrl.cpp
    replace "$pre2" "$post2" -- Space2Ctrl.cpp
  '';
}
