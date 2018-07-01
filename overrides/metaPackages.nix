# This one package depends on all of the packages we might want in a user
# profile so we don't need to keep track of everything separately. If you're on
# NixOS you can make these available using /etc/nixos/configuration.nix
# If you're using Nix standalone, or want per-user configuration, you can run
# a command like `nix-env -iA all` to install into your profile.
self: super:

with builtins;
with rec {
  inherit (super) lib;

  console =
    # Newer NixOS systems need fuse3 rather than fuse, but it doesn't exist
    # on older systems. We include it if available, otherwise we just warn.
    (if self ? fuse3
        then { inherit (self) fuse3; }
        else trace "WARNING: No fuse3 found" {}) //

    # We only need nix-repl for Nix 1.x, since 2.x has a built-in repl
    (if compareVersions nix.version "2" == -1
        then { inherit (self) nix-repl; }
        else {}) // {

    # These provide generally useful binaries
    inherit (haskellPackages) happy hlint pretty-show stylish-haskell;

    inherit (self) autossh artemis asv-nix bibclean bibtool binutils
                   brittany cabal-install2 cabal2nix cifs_utils ddgr dtach
                   dvtm entr exfat file fuse get_iplayer ghc ghostscript git
                   gnumake gnutls imagemagick inotify-tools jq lzip md2pdf
                   msmtp nix-diff youtube-dl openssh opusTools p7zip pamixer
                   pandocPkgs poppler_utils pmutils pptp psmisc python
                   racket silver-searcher sshfsFuse sshuttle smbnetfs sox st
                   tightvnc ts usbutils unzip wget wmname xbindkeys xcalib
                   xcape zip;

    inherit (xorg) xmodmap xproto;
  };

  graphical = self.stripOverrides (widgetThemes // {
    inherit (gnome3)      gcr;
    inherit (nixpkgs1709) abiword conkeror firefox gnumeric mplayer vlc;
    inherit (self)        acpi albert anonymous-pro-font arandr aspell audacious
      awf basic basket blueman cmus compton dillo droid-fonts emacsWithPkgs
      gcalcli gensgs iotop kbibtex_full keepassx leafpad lxappearance mu mupdf
      paprefs pavucontrol picard pidgin-with-plugins trayer w3m xsettingsd;
    inherit (xfce)        exo xfce4notifyd;
    inherit (xorg)        xkill;
    aspellDicts = aspellDicts.en;
  });

  packages = console // graphical;
};

assert lib.all self.isDerivation (attrValues packages) || self.die {
  error   = "Non-derivation in dependencies of meta-package";
  types   = lib.mapAttrs (_: typeOf) packages;
  nonDrvs = lib.mapAttrs (_: typeOf)
                         (lib.filterAttrs (_: x: !(self.isDerivation x))
                                          packages);
};

{
  overrides = {
    all   = self.buildEnv { name  = "all";   paths = attrValues graphical; };
    basic = self.buildEnv { name  = "basic"; paths = attrValues console;   };
  };

  tests = {
    all   = self.hasBinary self.all   "firefox";
    basic = self.hasBinary self.basic "ssh";
  };
}
