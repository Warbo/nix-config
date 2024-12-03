# This one package depends on all of the packages we might want in a user
# profile so we don't need to keep track of everything separately. If you're on
# NixOS you can make these available using /etc/nixos/configuration.nix
# If you're using Nix standalone, or want per-user configuration, you can run
# a command like `nix-env -iA all` to install into your profile.
self: super:

with builtins;
with super.lib;
with {
  go =
    name: paths:
    assert
      all isDerivation (attrValues paths)
      || abort (toJSON {
        inherit name;
        error = "Non-derivation in dependencies of meta-package";
        types = mapAttrs (_: typeOf) paths;
        nonDrvs = mapAttrs (_: typeOf) (filterAttrs (_: x: !(isDerivation x)) paths);
      });
    (if elem name [ "docGui" ] then self.lowPrio else (x: x)) (
      self.buildEnv {
        inherit name;
        paths = attrValues paths;
      }
    );
};
{
  # Packages before a ### are included in the ones after
  overrides = mapAttrs go {
    haskellCli = {
      inherit (self.haskellPackages) happy pretty-show;
      inherit (self)
        brittany
        cabal-install
        ghc
        ghcid
        hlint
        pretty-derivation
        stylish-haskell
        ;
    };

    ###

    devCli = {
      inherit (self)
        aws-sam-cli
        awscli
        binutils
        coreutils
        direnv
        entr
        #gcc
        git
        git-absorb
        #gnumake
        jq
        msgpack-tools
        nano
        #nix-diff
        nix-top
        nixfmt-rfc-style
        python3
        racket
        silver-searcher
        update-nix-fetchgit
        vim
        xidel
        ;
      inherit (self.python3Packages) black;
      inherit (self.warbo-packages)
        artemis
        #asv-nix
        ;
    };

    devGui = {
      inherit (self) emacs sqlitebrowser;
    };

    docCli = {
      inherit (self)
        anonymousPro
        bibclean
        bibtool
        droid-fonts
        ghostscript
        md2pdf
        pandocPkgs
        poppler_utils
        ;
      aspell = self.aspellWithDicts (dicts: [ dicts.en ]);
    };

    docGui = {
      inherit (self)
        abiword
        basket
        evince
        gnumeric
        gv
        kbibtex_full
        libreoffice
      ;
      inherit (self.xfce) mousepad;
      mupdf = self.without self.mupdf [
        "bin/mupdf-gl"
        "bin/mupdf-x11-curl"
      ];
    };

    games = {
      inherit (self) gensgs;
    };

    mediaCli = {
      inherit (self)
        acoustidFingerprinter
        alsa-utils
        imagemagick
        ffmpeg
        opusTools
        sox
        yt-dlp
        ;
    };

    mediaGui = {
      inherit (self)
        audacious
        cmus
        gimp
        mplayer
        pamixer
        paprefs
        pavucontrol
        picard
        vlc
        ;
    };

    netCli = {
      inherit (self)
        aria2
        autossh
        ddgr
        gnutls
        msmtp
        mu
        pptp
        sshuttle
        w3m
        wget
        ;
    };

    netGui = {
      inherit (self)
        dillo
        firefox
        transmission-qt
        uget
        x11vnc
        ;
      /*
        TODO: See if we can get this working again
        pidgin-with-plugins = self.pidgin.override {
          plugins = with self; [
            pidgin-otr
            # We disable gstreamer and farstream by default, to avoid problems
            # with dependencies (e.g. v4l-utils). Our config should fix those, so
            # we should use the unaltered pidgin definition.
            (pidgin-privacy-please.override { overrideGstreamer = false; })
          ];
        };
      */
    };

    # Keep these separate, since they won't work on non-NixOS systems (binaries
    # like fusermount need to be suid; NixOS has a workaround, other systems are
    # better off using their native package)
    inherit
      (rec {
        sysCli = sysCliNoFuse // {
          inherit (self) fuse fuse3;
        };

        sysCliNoFuse = {
          inherit (self.xorg) xmodmap;
          inherit (self)
            acpi
            binutils
            cifs-utils
            coreutils
            dtach
            dvtm
            exfat
            file
            htop
            inotify-tools
            libnotify
            lzip
            nano
            openssh
            p7zip
            pciutils
            pmutils
            psmisc
            rclone
            rsync
            screen
            smbnetfs
            sshfs-fuse
            ts
            unzip
            usbutils
            #warbo-utilities
            xz
            zbar
            zip
            ;
        };
      })
      sysCli
      sysCliNoFuse
      ;

    sysGui =
      self.iconThemes
      // self.widgetThemes
      // {
        inherit (self.gnome3) gcr;
        inherit (self.xfce) exo xfce4notifyd;
        inherit (self.xorg) xkill;
        inherit (self)
          arandr
          asunder
          awf
          blueman
          compton
          gksu
          iotop
          lxappearance
          rofi
          st
          trayer
          xsettingsd
          wmname
          xbindkeys
          xcalib
          xcape
          xpra
          ;
        inherit (libsForQt5) qt5ct qtstyleplugin-kvantum;
      };

    ###

    allCli = {
      inherit (self)
        devCli
        docCli
        mediaCli
        netCli
        sysCli
        ;
    };

    allGui = {
      inherit (self)
        devGui
        docGui
        games
        mediaGui
        netGui
        sysGui
        ;
    };

    ###

    allPkgs = {
      inherit (self) allCli allGui;
    };
  };

  tests = {
    all = self.hasBinary self.allPkgs "firefox";
    basic = self.hasBinary self.allCli "ssh";
    removals = self.runCommand "removed-undesirables" { inherit (self) allPkgs; } ''
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
