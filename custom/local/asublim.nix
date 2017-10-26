{ fetchFromGitHub, isBroken, libX11, libXrandr, mkBin, stdenv, withDeps, xosd }:

with rec {
  args = {
    name        = "asublim";
    buildInputs = [ libX11 libXrandr xosd ];
    src         = fetchFromGitHub {
      owner  = "enkiv2";
      repo   = "asublim";
      rev    = "b642015";
      sha256 = "0983d415aqd11z3am2wwvlhkk0cxd6iyajz5afjyiggvf77xlgaa";
    };
  };
  installPhase = ''
    mkdir -p  "$out/bin"
    cp sublim "$out/bin/asublim"
  '';

  # Checks that our installPhase is still needed
  asublim = withDeps [ (isBroken (stdenv.mkDerivation args)) ]
                     (stdenv.mkDerivation (args // { inherit installPhase; }));
};

mkBin {
  name   = "asublim";
  paths  = [ asublim ];
  vars   = { DISPLAY = ":0"; };
  script = ''
    #!/usr/bin/env bash

    # Defaults taken from xsublim man page, with +1 to avoid float errors
    [[ -n "$DELAY_SHOW_MIN" ]] || DELAY_SHOW_MIN=40000
    [[ -n "$DELAY_SHOW_MAX" ]] || DELAY_SHOW_MAX=40001
    [[ -n "$DELAY_WORD_MIN" ]] || DELAY_WORD_MIN=100000
    [[ -n "$DELAY_WORD_MAX" ]] || DELAY_WORD_MAX=100001

    # My laptop :)
    [[ -n "$WIDTH"  ]] ||  WIDTH=1024
    [[ -n "$HEIGHT" ]] || HEIGHT=768

    asublim --delayShowMin "$DELAY_SHOW_MIN" \
            --delayShowMax "$DELAY_SHOW_MAX" \
            --delayWordMin "$DELAY_WORD_MIN" \
            --delayWordMax "$DELAY_WORD_MAX" \
            --screen-width "$WIDTH" --screen-height "$HEIGHT" "$@"
  '';
}
