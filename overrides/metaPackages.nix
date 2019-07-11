# This one package depends on all of the packages we might want in a user
# profile so we don't need to keep track of everything separately. If you're on
# NixOS you can make these available using /etc/nixos/configuration.nix
# If you're using Nix standalone, or want per-user configuration, you can run
# a command like `nix-env -iA all` to install into your profile.
self: super:

with builtins;
with super.lib;
with {
  go = name: paths:
    assert all isDerivation (attrValues paths) || self.die {
      inherit name;
      error   = "Non-derivation in dependencies of meta-package";
      types   = mapAttrs (_: typeOf) paths;
      nonDrvs = mapAttrs (_: typeOf)
                         (filterAttrs (_: x: !(isDerivation x))
                                      paths);
    };
    (if elem name [ "docGui" ]
        then self.lowPrio
        else (x: x))
      (self.buildEnv { inherit name; paths = attrValues paths; });
};
{
  # Packages before a ### are included in the ones after
  overrides = mapAttrs go {
    haskellCli = {
      inherit (self.haskellPackages)
        ghcid
        happy
        hlint
        nix-derivation
        pretty-show
        stylish-haskell
        ;
      inherit (self)
        brittany
        cabal-install
        ghc
        cabal2nix
        ;
    };

    ###

    devCli = {
      inherit (self)
        artemis
        asv-nix
        git
        gnumake
        haskellCli
        jq
        msgpack-tools
        nix-diff
        nix_release
        nix-top
        python
        racket
        silver-searcher
        xidel
        ;
    };

    docCli = {
      inherit (self)
        anonymous-pro-font
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
        gimp
        gnumeric
        gv
        kbibtex_full
        leafpad
        libreoffice
        mu
        ;
      mupdf = self.without self.mupdf [ "bin/mupdf-gl" "bin/mupdf-x11-curl" ];
    };

    mediaCli = {
      inherit (self)
        acoustidFingerprinter
        alsaUtils
        imagemagick
        ffmpeg
        opusTools
        sox
        ;
    };

    mediaGui = {
      inherit (self)
        audacious
        cmus
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
        autossh
        cifs_utils
        ddgr
        #gcalcli
        get_iplayer
        gnutls
        msmtp
        openssh
        pptp
        sshfsFuse
        sshuttle
        smbnetfs
        tightvnc
        w3m
        wget
        youtube-dl
        ;
    };

    netGui = {
      inherit (self)
        conkeror
        dillo
        firefoxBinary
        pidgin-with-plugins
        uget
        ;
    };

    sysCli = {
      inherit (self.xorg) xmodmap;
      inherit (self)
        acpi
        binutils
        dtach
        dvtm
        emacs
        entr
        exfat
        file
        fuse
        fuse3
        inotify-tools
        libnotify
        lzip
        p7zip
        pmutils
        psmisc
        st
        ts
        usbutils
        unzip
        warbo-utilities
        wmname
        xbindkeys
        xcalib
        xcape
        zip
        ;
    };

    sysGui = self.widgetThemes // {
      inherit (self.gnome3) gcr;
      inherit (self.xfce  ) exo xfce4notifyd;
      inherit (self.xorg  ) xkill;
      inherit (self)
        arandr
        asunder
        awf
        blueman
        compton
        dmenu2
        gensgs
        gksu
        iotop
        keepassx
        lxappearance
        trayer
        xsettingsd
        ;
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
        docGui
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
    all      = self.hasBinary self.allPkgs "firefox";
    basic    = self.hasBinary self.allCli  "ssh";
    removals = self.runCommand "removed-undesirables"
      { inherit (self) allPkgs; }
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
