{
  warbo-utilities ? import ../warbo-utilities.nix,
  nix-helpers ? warbo-utilities.warbo-packages.nix-helpers,
  nixpkgs ? nix-helpers.nixpkgs,
  buildPackages ? nixpkgs.buildPackages,
  nixpkgs-lib ? nix-helpers.nixpkgs-lib,
  runCommand ? nixpkgs.runCommand,
}:
with rec {
  inherit (builtins) attrValues;
  inherit (nixpkgs-lib) concatStringsSep escapeShellArg mapAttrs;

  name = "buuf-for-many-desktops";

  camera = ./camera.png;
  chat = ./chat.png;
  clock = ./clock.png;
  cow = ./cow.png;
  cross = ./x.png;
  envelope = ./fat-envelope.png;
  phone = ./phone.png;

  replacements = {
    "actions/media-playback-start.png" = "actions/arrow.png";
    "actions/gtk-no.png" = cross;
    "actions/stock_no.png" = cross;
    "actions/button_cancel.png" = cross;
    "actions/dialog-no.png" = cross;
    "actions/dialog-no-symbolic.png" = cross;
    "actions/stock_calc-cancel.png" = cross;
    "actions/stock_not.png" = cross;
    "actions/cancel.png" = cross;
    "apps/cantata.png" = "mimetypes/media-audio.png";
    "apps/emacs.png" = cow;
    "apps/foot.png" = "apps/Terminal.png";
    "apps/org.gnome.Calls.png" = phone;
    "apps/org.gnome.Calls-symbolic.png" = phone;
    "org.gnome.clocks.png" = clock;
    "org.gnome.Geary.png" = envelope;
    "org.gnome.Podcasts.png" = "devices/stock_mic.png";
    "apps/org.gnome.Settings.png" = "apps/cogs.png";
    "org.postmarketos.Megapixels.png" = camera;
    "apps/sm.puri.Chatty.png" = chat;
    "apps/sm.puri.Chatty-symbolic.png" = chat;
    "emotes/opinion-no.png" = cross;
  };

  mkCommand =
    location: new: with { esc = x: escapeShellArg "${x}"; }; ''
      LOCATION='${esc location}'
      rm -f "$LOCATION"
      ln -sv '${esc new}' "$LOCATION"
    '';

  commands = mapAttrs mkCommand replacements;
};
runCommand name
  {
    buildInputs = [ buildPackages.gtk3 ];
    raw = fetchGit {
      name = "buuf-src";
      url = "https://git.disroot.org/eudaimon/buuf-nestort.git";
      ref = "master";
      rev = "0b0cca8346d86d56c2e31e2cfe8e924f6a0bfb64";
    };
  }
  ''
    DEST="OUT/share/icons/${name}"
    mkdir -p "$(dirname "$DEST")"
    cp -rs "$raw" "$DEST"
    chmod +w -R "$DEST"
    pushd "$DEST"
    ${concatStringsSep "\n" (attrValues commands)}
    popd
    gtk-update-icon-cache --ignore-theme-index "$DEST"
    mv OUT "$out"
  ''
