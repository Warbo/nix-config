# This one package depends on all of the packages we might want in a user
# profile so we don't need to keep track of everything separately. If you're on
# NixOS you can make these available using /etc/nixos/configuration.nix
# If you're using Nix standalone, or want per-user configuration, you can run
# a command like `nix-env -iA all` to install into your profile.
self: super:

with builtins;
with rec {
  console = {
    # These provide generally useful binaries
    inherit (self.haskellPackages) ghcid happy pretty-show;
    inherit (self.xorg) xmodmap;
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
      cabal-install
      cifs_utils
      ddgr
      dtach
      dvtm
      emacs
      entr
      exfat
      file
      fuse
      fuse3
      get_iplayer
      ghc
      ghostscript
      git
      gnumake
      gnutls
      hlint
      imagemagick
      inotify-tools
      jq
      libnotify
      lzip
      md2pdf
      msgpack-tools
      msmtp
      nix-diff
      nix_release
      nix-top
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
      stylish-haskell
      tightvnc
      ts
      usbutils
      unzip
      warbo-utilities
      wget
      wmname
      xbindkeys
      xcalib
      xcape
      youtube-dl
      zip
      ;
  };

  graphical = self.stripOverrides
    (self.widgetThemes // {
       inherit (self.gnome3) gcr;
       inherit (self.xfce  ) exo xfce4notifyd;
       inherit (self.xorg  ) xkill;
       inherit (self)
         abiword
         acpi
         anonymous-pro-font
         arandr
         aspellWithDict
         asunder
         audacious
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
         evince
         firefoxBinary
         gcalcli
         gensgs
         gksu
         gnumeric
         gv
         iotop
         kbibtex_full
         keepassx
         leafpad
         lxappearance
         mplayer
         mu
         paprefs
         pavucontrol
         picard
         pidgin-with-plugins
         trayer
         uget
         vlc
         w3m
         xsettingsd
         ;

       mupdf = self.without self.mupdf [
         "bin/mupdf-gl" "bin/mupdf-x11-curl"
       ];
     });

  packages = console // graphical;
};

{
  overrides = {
    all   = self.buildEnv { name  = "all";   paths = attrValues graphical; };
    basic = self.buildEnv { name  = "basic"; paths = attrValues console;   };
  };

  tests =
    with super.lib;
    assert all isDerivation (attrValues packages) || self.die {
      error   = "Non-derivation in dependencies of meta-package";
      types   = mapAttrs (_: typeOf) packages;
      nonDrvs = mapAttrs (_: typeOf)
                         (filterAttrs (_: x: !(isDerivation x))
                                      packages);
    };
    {
      all      = self.hasBinary self.all   "firefox";
      basic    = self.hasBinary self.basic "ssh";
      removals = self.runCommand "removed-undesirables" { inherit (self) all; }
        ''
          FAIL=0
          for F in bin/mupdf-gl bin/mupdf-x11-curl
          do
            if [[ -e "$all/$F" ]]
            then
              FAIL=1
              echo "Found '$F', which should have been removed" 1>&2
            fi
          done
          if [[ "$FAIL" -gt 0 ]]
          then
            echo "Removal didn't work" 1>&2
            exit 1
          fi
          mkdir "$out"
        '';
    };
}
