# This contains the stuff we expect to be available for non-interactive scripts
{ self }:

with self;

buildEnv {
  name  = "basic";
  paths = [
    autossh
    artemis
    binutils
    unstableHaskellPackages.cabal-install
    (tincify haskellPackages.cabal2nix {})
    dtach
    dvtm
    file
    get_iplayer
    ghc
    ghostscript
    git
    gnumake
    haskellPackages.happy
    jq
    md2pdf
    msmtp
    nix-repl
    openssh
    opusTools
    p7zip
    pamixer
    pandoc
    panhandle
    panpipe
    poppler_utils
    pmutils
    psmisc
    python
    racket
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
    warbo-utilities
    wget
    wmname
    xbindkeys
    xcalib
    xcape
    xorg.xmodmap
    xorg.xproto
    youtube-dl
    zip
  ];
}
