{ cmake, fetchFromGitHub, gtk3, pkgconfig, qt4, replace, runCommand, stdenv }:

with rec {
  src = fetchFromGitHub {
    owner  = "lxde";
    repo   = "qt-gtk-engine";
    rev    = "00a1c9a";
    sha256 = "1j97l38ryvjjvjl48aacna06dn9016pi6qlnp8l0xnlpxxw8696m";
  };

  patched = runCommand "patched"
    {
      inherit src;
      buildInputs = [ replace ];
      old         = "app = new QApplication(0, NULL);";
      new         = ''char* appName  = "name";
                      int   argCount = 1;
                      app = new QApplication(argCount, &appName);'';
    }
    ''
      cp -r "$src" "$out"
      chmod +w -R  "$out"

      replace "$old" "$new" < "$src/gtk3/main.cpp" \
                            > "$out/gtk3/main.cpp"
    '';

  theme = stdenv.mkDerivation {
    src = patched;
    name        = "qt-gtk-engine";
    buildInputs = [ cmake gtk3 pkgconfig qt4 ];
  };
};
theme
