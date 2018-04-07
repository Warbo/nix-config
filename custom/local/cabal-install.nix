{ dnsutils, gcc, ghc, pkgconfig, runCommand, super, zlib }:

with rec {
  old    = super.cabal-install.version;
  new    = "2.2.0.0";
  forced = runCommand "cabal-install-forced-${new}"
    {
      buildInputs = [
        dnsutils
        gcc
        ghc
        pkgconfig
        super.cabal-install
        zlib
        zlib.dev
      ];
    }
    ''
      export HOME="$out/home"
      mkdir -p "$HOME"
      cabal update
      cabal install -v3 cabal-install-2.2.0.0
      ln -s "$HOME/.cabal/bin" "$out/bin"
    '';
};

with builtins;
if compareVersions new old == 1
   then forced
   else trace "FIXME: Nixpkgs cabal version is ${old}, we're forcing ${new}"
              super.cabal-install
