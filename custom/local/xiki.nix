{ emacs, fetchFromGitHub, makeWrapper, ncurses, ruby, stdenv }:

stdenv.mkDerivation {
  name = "xiki";
  src  = fetchFromGitHub {
    owner  = "trogdoro";
    repo   = "xiki";
    rev    = "f887ec8";
    sha256 = "1d6mmr5rap1vzd651cdwikh9liqfdz0hbyfxsldjzawjllfszhp0";
  };

  TERM         = "dumb";  # To prevent tput complaining
  buildInputs  = [ emacs makeWrapper ncurses.out ruby ];
  patchPhase   = ''
    # Installer looks for non-existent /xiki without this patch
    sed -i -e "s@\"/xiki\"@\"$out\"@g" misc/install/install_when_flag.rb
  '';
  installPhase = ''
    # Xiki tries to install into HOME, which doesn't suit Nix at all
    export HOME="$out"
    cp -r . "$out"

    # Run the installer
    "$out/bin/xsh" --install

    # Give all the binaries access to Emacs and Ruby
    for F in "$out"/bin/*
    do
      wrapProgram "$F" --prefix PATH : "${emacs}/bin" \
                       --prefix PATH : "${ruby}/bin"
    done
  '';
}
