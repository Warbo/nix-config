# This contains the stuff we expect to be available for non-interactive scripts
{ self }:

with builtins;
with self;
with {
  extras = if self ? fuse3
              then [ fuse3 ]
              else trace "WARNING: No fuse3 found" [];
};
buildEnv {
  name  = "basic";
  paths = extras ++ [
    autossh
    artemis
    bibclean
    bibtool
    binutils
    brittany
    cabal2nix
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
    haskellPackages.cabal-install
    haskellPackages.happy
    haskellPackages.hlint
    haskellPackages.pretty-show
    haskellPackages.stylish-haskell
    inotify-tools
    jq
    lzip
    md2pdf
    msmtp
    nix-repl
    nixpkgs1709.youtube-dl
    openssh
    opusTools
    p7zip
    pamixer
    pandocPkgs
    poppler_utils
    pmutils
    pptp
    psmisc
    python
    nixpkgs1609.racket
    cifs_utils
    silver-searcher
    sshfsFuse
    sshuttle
    smbnetfs
    sox
    st
    imagemagick
    tightvnc
    ts
    usbutils
    unzip
    wget
    wmname
    xbindkeys
    xcalib
    xcape
    xorg.xmodmap
    xorg.xproto
    zip
  ];
}
