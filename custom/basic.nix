# This contains the stuff we expect to be available for non-interactive scripts
self: super:

with self;

{
  basic = buildEnv {
    name  = "basic";
    paths = [
      autossh
      binutils
      dtach
      dvtm
      file
      get_iplayer
        # FIXME: These two should be dependencies of get_iplayer
        perlPackages.XMLSimple
        ffmpeg
      ghostscript
      git
      gnumake
      jq
      md2pdf
      msmtp
      nix-repl
      openssh
      pamixer
      panhandle
      panpipe
      poppler_utils
      pmutils
      psmisc
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
  };
}
