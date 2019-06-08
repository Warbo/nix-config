# Override broken or non-optimal packages from <nixpkgs> and elsewhere
self: super:

with builtins;
with super.lib;
with rec {
  get = reason: name: version:
    trace "FIXME: Taking ${name} from nixpkgs${version} because ${reason}"
          (getAttr name (getAttr "nixpkgs${version}" self));

  cached = name: get "it's cached" name "1709";

  broken1903 = name: get "it's broken on 19.03" name "1809";
};
{
  overrides = {
    audacious = cached "audacious";

    conkeror = get "it's broken on 18.03+" "conkeror" "1703";

    # Newer NixOS systems need fuse3 rather than fuse, but it doesn't exist
    # on older systems. We include it if available, otherwise we just warn.
    fuse3 = super.fuse3 or super.nothing;

    gensgs = broken1903 "gensgs";

    get_iplayer = trace "FIXME: Avoiding 19.03 breakages"
                        super.get_iplayer.override {
                          inherit (self.nixpkgs1809) get_iplayer;
                        };

    gimp = cached "gimp";

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

    libreoffice = cached "libreoffice";

    mplayer = cached "mplayer";

    # We only need nix-repl for Nix 1.x, since 2.x has a built-in repl
    nix-repl = if compareVersions self.nix.version "2" == -1
                  then super.nix-repl
                  else nothing;

    picard = broken1903 "picard";

    stylish-haskell = trace "FIXME: Haskell yaml package broken on 18.09"
                            self.nixpkgs1803.haskellPackages.stylish-haskell;

    thermald = broken1903 "thermald";

    vlc = cached "vlc";

    # xproto was replaced by xorgproto
    xorgproto = super.xorg.xorgproto or super.xorg.xproto;
  };

  tests =
    with super.lib;
    with rec {
      stillBroken = pkg: {
        name  = "${pkg}StillNeedsOverride";
        value = self.isBroken (getAttr pkg super);
      };

      allStillBroken = pkgs: listToAttrs (map stillBroken pkgs);
    };
    { libproxyWorks = self.libproxy; } // allStillBroken [
      "gensgs"
      "picard"
      "thermald"
    ];
}
