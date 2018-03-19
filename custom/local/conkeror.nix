{ firefox, latestGit, makeWrapper, stdenv, unzip }:

stdenv.mkDerivation rec {
  inherit firefox;
  pkgname      = "conkeror";
  version      = "git";
  name         = "${pkgname}-${version}";
  src          = latestGit {
    url    = https://github.com/retroj/conkeror.git;
    stable = {
      rev    = "97115c2";
      sha256 = "1ikjzfvp7wm9f0644d0dxdlfbm2xf46fxm7njxwnb9s086c9rrvw";
    };
  };
  buildInputs  = [ unzip makeWrapper ];
  installPhase = ''
    mkdir -p "$out/libexec/conkeror"
    cp -r * "$out/libexec/conkeror/"

    makeWrapper "$firefox/bin/firefox" "$out/bin/conkeror" \
      --add-flags "-app $out/libexec/conkeror/application.ini"
  '';
}
