# Override broken or non-optimal packages from <nixpkgs> and elsewhere
self: super:

with builtins;
with super.lib;
{
  overrides = {
    audacious = trace "FIXME: Use latest packages (if build is quicker)"
                      self.nixpkgs1709.audacious;

    conkeror = trace "FIXME: Conkeror broke on 18.03+"
                     self.nixpkgs1703.conkeror;

    # Newer NixOS systems need fuse3 rather than fuse, but it doesn't exist
    # on older systems. We include it if available, otherwise we just warn.
    fuse3 = super.fuse3 or super.nothing;

    gensgs = trace "FIXME: Avoiding 19.03 breakages" self.nixpkgs1809.gensgs;

    get_iplayer = trace "FIXME: Avoiding 19.03 breakages"
                        super.get_iplayer.override {
                          inherit (self.nixpkgs1809) get_iplayer;
                        };

    gimp = trace ''
      FIXME: Using gimp from nixpkgs 17.03, since that is cached on
      hydra.nixos.org, but newer i686 versions aren't.
    '' self.nixpkgs1709.gimp;

    hlint = trace "FIXME: Haskell yaml package broken on 18.09"
                  self.nixpkgs1803.haskellPackages.hlint;

    libproxy = trace ''FIXME: Removing flaky, heavyweight SpiderMonkey
                       dependency from libproxy''
                     super.libproxy.overrideDerivation (old: {
      buildInputs  = filter (x: !(hasPrefix "spidermonkey" x.name))
                            old.buildInputs;
      preConfigure = replaceStrings [ ''"-DWITH_MOZJS=ON"'' ]
                                    [ ""                    ]
                                    old.preConfigure;
    });

    libreoffice = trace ''
      FIXME: Using libreoffice from nixpkgs 17.03, since that is cached on
      hydra.nixos.org, but newer i686 versions aren't.
    '' self.nixpkgs1709.libreoffice;

    mplayer = trace "FIXME: Use latest packages (if build is quicker)"
                    self.nixpkgs1709.mplayer;

    # We only need nix-repl for Nix 1.x, since 2.x has a built-in repl
    nix-repl = if compareVersions self.nix.version "2" == -1
                  then super.nix-repl
                  else nothing;

    picard = trace "FIXME: Avoiding 19.03 breakages" self.nixpkgs1809.picard;

    stylish-haskell = trace "FIXME: Haskell yaml package broken on 18.09"
                            self.nixpkgs1803.haskellPackages.stylish-haskell;

    thermald = trace "FIXME: thermald broken on 19.03"
                     super.nixpkgs1803.thermald;

    vlc = trace "FIXME: Use latest packages (if build is quicker)"
                self.nixpkgs1709.vlc;

    # xproto was replaced by xorgproto
    xorgproto = super.xorg.xorgproto or super.xorg.xproto;
  };

  tests = { inherit (self) libproxy; };
}
