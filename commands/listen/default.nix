{ mpv, pi4 ? (import ../../commands.nix { }).pi4, writeShellApplication }:
writeShellApplication {
  name = "listen";
  runtimeInputs = [ mpv pi4 ];
  text = ''
    ADDR=$(pi4)
    mpv "$@" "http://$ADDR:6666/mpd.''${FORMAT:-flac}"
  '';
}
