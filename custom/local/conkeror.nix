{ firefox, latestGit, makeWrapper, stdenv, unzip }:

with rec {

};
stdenv.mkDerivation rec {
  inherit firefox;
  pkgname      = "conkeror";
  version      = "git";
  name         = "${pkgname}-${version}";
  src          = latestGit { url = https://github.com/retroj/conkeror.git; };
  buildInputs  = [ unzip makeWrapper ];
  installPhase = ''
    mkdir -p "$out/libexec/conkeror"
    cp -r * "$out/libexec/conkeror/"

    makeWrapper "$firefox/bin/firefox" "$out/bin/conkeror" \
      --add-flags "-app $out/libexec/conkeror/application.ini"
  '';
}
