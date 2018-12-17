# This one package depends on all of the packages we might want in a user
# profile so we don't need to keep track of everything separately. If you're on
# NixOS you can make these available using /etc/nixos/configuration.nix
# If you're using Nix standalone, or want per-user configuration, you can run
# a command like `nix-env -iA all` to install into your profile.
self: super:

with builtins;
with rec {
  inherit (super) lib;

  i686Cache =
    with rec {
      msg = name: trace ''
                    Using ${name} from nixpkgs 17.03, since that is cached on
                    hydra.nixos.org, but newer i686 versions aren't.
                  '';

      get = acc: name: acc // {
        "${name}" = getAttr name (if currentSystem == "i686-linux"
                                     then msg name self.nixpkgs1703
                                     else self);
      };
    };
    foldl' get {};

  console =
    # Newer NixOS systems need fuse3 rather than fuse, but it doesn't exist
    # on older systems. We include it if available, otherwise we just warn.
    (if self ? fuse3
        then { inherit (self) fuse3; }
        else trace "WARNING: No fuse3 found" {}) //

    # We only need nix-repl for Nix 1.x, since 2.x has a built-in repl
    (if compareVersions self.nix.version "2" == -1
        then { inherit (self) nix-repl; }
        else {}) // {

    # These provide generally useful binaries
    inherit (self.haskellPackages) ghcid happy hlint pretty-show
                                   stylish-haskell;

    inherit (self)
      acoustidFingerprinter
      alsaUtils
      artemis
      asv-nix
      autossh
      bibclean
      bibtool
      binutils
      brittany
      cabal-install2
      cifs_utils
      ddgr
      dtach
      dvtm
      entr
      exfat
      file
      fuse
      get_iplayer
      ghc
      ghostscript
      git
      gnumake
      gnutls
      imagemagick
      inotify-tools
      jq
      libnotify
      lzip
      md2pdf
      msgpack-tools
      msmtp
      nix-diff
      openssh
      opusTools
      p7zip
      pamixer
      pandocPkgs
      pinnedCabal2nix
      poppler_utils
      pmutils
      pptp
      psmisc
      python
      racket
      silver-searcher
      sshfsFuse
      sshuttle
      smbnetfs
      sox
      st
      tightvnc
      ts
      usbutils
      unzip
      wget
      wmname
      xbindkeys
      xcalib
      xcape
      youtube-dl
      zip
      ;

    inherit (self.xorg) xmodmap xproto;
  };

  graphical = self.stripOverrides
    (self.widgetThemes // i686Cache [ "libreoffice" "gimp" ] // {
       inherit (self.gnome3)
         gcr;
       inherit (trace "FIXME: Use latest packages (if build is quicker)" self.nixpkgs1709)
         abiword audacious firefox mplayer vlc;
       inherit (self)
         acpi
         anonymous-pro-font
         arandr
         aspell
         asunder
         awf
         basic
         basket
         blueman
         cmus
         compton
         conkeror
         dillo
         dmenu2
         droid-fonts
         emacsWithPkgs
         evince
         gcalcli
         gensgs
         gksu
         gnumeric
         iotop
         kbibtex_full
         keepassx
         leafpad
         lxappearance
         mu
         mupdf
         paprefs
         pavucontrol
         picard
         pidgin-with-plugins
         trayer
         uget
         w3m
         xsettingsd;
       inherit (self.xfce) exo xfce4notifyd;
       inherit (self.xorg) xkill;
       aspellDicts = self.aspellDicts.en;
     });

  packages = console // graphical;
};

{
  overrides = {
    all   = self.buildEnv { name  = "all";   paths = attrValues graphical; };
    basic = self.buildEnv { name  = "basic"; paths = attrValues console;   };
  };

  tests =
    with lib;
    assert all isDerivation (attrValues packages) || self.die {
      error   = "Non-derivation in dependencies of meta-package";
      types   = mapAttrs (_: typeOf) packages;
      nonDrvs = mapAttrs (_: typeOf)
                         (filterAttrs (_: x: !(isDerivation x))
                                      packages);
    };
    {
      all   = self.hasBinary self.all   "firefox";
      basic = self.hasBinary self.basic "ssh";
    };
}
