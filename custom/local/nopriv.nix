{ fetchFromGitHub, makeWrapper, pythonPackages, stdenv }:

stdenv.mkDerivation {
  name = "nopriv";
  src  = fetchFromGitHub {
    owner  = "RaymiiOrg";
    repo   = "NoPriv";
    rev    = "032ce72";
    sha256 = "16wg3pw81gj22www40znkfdh8b0625i3grrd4rd0crdkygxpd873";
  };

  env = with pythonPackages; python.withPackages (p: [
  ]);

  buildInputs  = [ makeWrapper ];

  # Patch to expand '~' into HOME
  buildPhase   = ''
    cp -r "$src" ./src
    substituteInPlace ./src/nopriv.py \
      --replace "'~/.config/nopriv.ini'," \
                "os.path.expanduser('~/.config/nopriv.ini'),"
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    cp -r ./src "$out/src"
    makeWrapper "$out/src/nopriv.py" "$out/bin/nopriv" \
      --prefix PATH : "$env/bin"
  '';
}
