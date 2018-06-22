# These packages are taken straight from whichever nixpkgs set we're overriding,
# and crucially they do no get their dependencies replaced by our overrides. For
# example if one of these packages 'foo' depends on 'bar' and we have an
# override for 'bar' (e.g. in local/), then this 'foo' package will *not* use
# that override.
# This is mostly useful for avoiding dependency overrides for Nix's "bootstrap"
# packages; these are things like 'xz' which Nix itself depends on. Since we
# override *everything* provided by <nixpkgs>, to ensure we're using pinned
# nixpkgs versions, we end up replacing these bootstrap packages, which causes a
# *huge* diff from the normal nixpkgs. This would stop us using binary caches.
self: super:

with builtins;
with super.lib;
with rec {
  # These were found using 'nix-diff' to compare 'nix' against 'nixpkgs1803.nix'
  # and trying to minimise the difference.
  bootstrapPkgs = [
    "acl" "attr" "bash" "bzip2" "coreutils" "gawk" "gnugrep" "gnused" "gzip"
    /*"libiconv"*/ "patchelf" "pcre" /*"perl"*/ "xz" "zlib"
  ];

  # These take a while to build, and can cause cascades requiring other packages
  # to be rebuilt, when we don't actually care about overriding them.
  slowPkgs = [ "gcc" "nix" ];

  all = bootstrapPkgs ++ slowPkgs;

  # Where we should take pristine packages from
  source = getAttr super.version self;

  # These should end up pristine. If not, either our untouchanbles aren't
  # propagating properly or, perhaps, some other dependency has changed.
  consequences = [
    # Regressions
    "curl"
    "libuv"

    # From basic.nix
    "autossh"
    "binutils"
    "dtach"
    "dvtm"
    "entr"
    "exfat"
    "file"
    "fuse"
    "ghostscript"
    "git"
    "gnumake"
    "gnutls"
    "imagemagick"
    "inotify-tools"
    "jq"
    "lzip"
    "msmtp"
    "nix-repl"
    "openssh"
    "opusTools"
    "p7zip"
    "pamixer"
    "poppler_utils"
    "pmutils"
    "pptp"
    "psmisc"
    "python"
    "cifs_utils"
    "silver-searcher"
    "sshfsFuse"
    "sshuttle"
    "smbnetfs"
    "sox"
    "st"
    "tightvnc"
    "ts"
    "usbutils"
    "unzip"
    "wget"
    "wmname"
    "xbindkeys"
    "xcalib"
    "xcape"
    "zip"

    # From all.nix
    "abiword"
    "acpi"
    "albert"
    "arandr"
    "aspell"
    "audacious"
    "awf"
    "blueman"
    "compton"
    "dillo"
    "firefox"
    "gensgs"
    "iotop"
    "keepassx"
    "leafpad"
    "lxappearance"
    "mplayer"
    "mupdf"
    "networkmanagerapplet"
    "paprefs"
    "pavucontrol"
    "picard"
    "trayer"
    "vlc"
    "w3m"
    "xsettingsd"
  ];
};
{
  pkgs  = genAttrs all (n: getAttr n source);
  tests = genAttrs (all ++ consequences) (n:
    with self;
    runCommand "pristine-${n}"
      (withNix {
        inherit n;
        buildInputs = [ nix-diff ];
        ours        = "${getAttr n self}";
        pure        = "${getAttr n source}";
      })
      ''
        if [[ "x$ours" = "x$pure" ]]
        then
          echo "Our '$n' package is pristine" 1>&2
          mkdir "$out"
        else
          echo "Package '$n' differs from pristine nixpkgs" 1>&2
          oursDrv=$(nix-store -q --deriver "$ours")
          pureDrv=$(nix-store -q --deriver "$pure")
          nix-diff "$pureDrv" "$oursDrv"
        fi
      '');
}
