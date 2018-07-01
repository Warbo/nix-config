# This contains useful stuff we would like to be available for user shells and
# general one-off scripts. We can install it using e.g. 'nix-env -iA basic' and
# not have to worry about managing each package individually. See also: all.nix
self: super:

with builtins;
rec {
  overrides = {
    basic = buildEnv {
      name  = "basic";
      paths =
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
    };
  };

  tests = self.hasBinary self.basic "ssh";
}
