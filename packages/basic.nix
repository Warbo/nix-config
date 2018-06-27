# This contains useful stuff we would like to be available for user shells and
# general one-off scripts. We can install it using e.g. 'nix-env -iA basic' and
# not have to worry about managing each package individually. See also: all.nix
{ autossh, artemis, asv-nix, bibclean, bibtool, binutils, brittany, buildEnv,
  cabal-install2, cabal2nix, ddgr, dtach, dvtm, entr, exfat, file, fuse,
  fuse3 ? null, get_iplayer, ghc, ghostscript, git, gnumake, gnutls, hasBinary,
  haskellPackages, inotify-tools, jq, lib, lzip, md2pdf, msmtp, nix-diff,
  nix-repl, youtube-dl, openssh, opusTools, p7zip, pamixer, pandocPkgs,
  poppler_utils, pmutils, pptp, psmisc, python, nixpkgs1609, cifs_utils,
  silver-searcher, sshfsFuse, sshuttle, smbnetfs, sox, st, imagemagick,
  tightvnc, ts, usbutils, unzip, wget, withDeps, wmname, xbindkeys, xcalib,
  xcape, xorg, zip }@args:

with builtins;
with lib;
with rec {
  # We assume that everything in args is a package we want to include, except
  # for the names given in this list.
  nonPackages = [
    "buildEnv" "fuse3" "hasBinary" "haskellPackages" "lib" "nixpkgs1609"
    "withDeps" "xorg"
  ];

  # Anything we can't take as a simple argument, e.g. nested attributes
  extras = concatLists [
    # Newer NixOS systems need fuse3 rather than fuse, but it doesn't exist on
    # older systems. We include it if available, otherwise we just warn.
    (if fuse3 == null
        then trace "WARNING: No fuse3 found" []
        else [ fuse3 ])

    # These provide generally useful binaries
    (with haskellPackages; [ Agda happy hlint pretty-show stylish-haskell ])

    # Newer versions of racket are broken on i686
    # FIXME: We should improve this, e.g. by checking and warning or something
    [ nixpkgs1609.racket ]

    (with xorg; [ xmodmap xproto ])
  ];

  packages = extras ++ map (name: getAttr name args)
                           (filter (name: !(elem name nonPackages))
                                   (attrNames args));

  pkg = buildEnv {
    name  = "basic";
    paths = packages;
  };

  tested = withDeps [ (hasBinary pkg "ssh") ] pkg;
};
{
  pkg   = tested;
  tests = tested;
}
