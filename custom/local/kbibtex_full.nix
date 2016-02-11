# Shamelessly taken from https://github.com/NixOS/nixpkgs/pull/10219
# FIXME: This is using FAR too many dependencies; many are taken verbatim from
# that digikam patch, and are hence unused by kbibtex
{ stdenv, fetchurl, automoc4, boost, shared_desktop_ontologies, cmake
, eigen, lcms, gettext, jasper, lensfun
, libgphoto2, libjpeg, libpgf, libtiff
, libusb1, liblqr1, mysql, opencv, perl, phonon, pkgconfig
, qca2, qimageblitz, qjson, qt4, soprano, poppler_qt4, kde4

# Optional build time dependencies
, lcms2, libxslt

# Plugins optional build time dependencies
, gdk_pixbuf, imagemagick
, libgpod

# Supplementary packages required only by the wrapper.
, bash, makeWrapper
, runCommand, shared_mime_info, writeScriptBin
}:

# Extract a bunch of dependencies from kde4
with { inherit (kde4) kdelibs kdepimlibs libkdcraw libkexiv2 libkipi okular
                      kfilemetadata libkvkontakte kde_runtime kde_baseapps
                      oxygen_icons; };
let
  version = "0.4";
  pName = "kbibtex-${version}";

  build = stdenv.mkDerivation rec {
    name = "kbibtex-build-${version}";

    src = fetchurl {
      url = "http://download.gna.org/kbibtex/${version}/kbibtex-${version}.tar.bz2";
      sha256 = "1hq0az0dp96195z26wjfwj9ynd57pfv13f1xcl5vbsswcjfrczws";
    };

    nativeBuildInputs = [
      automoc4 cmake gettext perl pkgconfig
    ];

    buildInputs = [
      boost eigen jasper kdelibs kdepimlibs lcms lensfun
      libgphoto2 libjpeg libkdcraw libkexiv2 libkipi liblqr1 libpgf
      libtiff mysql.lib opencv phonon qca2 qimageblitz qjson qt4
      shared_desktop_ontologies soprano poppler_qt4
    ] ++ [
      # Optional build time dependencies
      kfilemetadata
      lcms2 libxslt
    ] ++ [
      # Plugins optional build time dependencies
      gdk_pixbuf imagemagick libgpod
      libkvkontakte
    ];

    patchPhase = ''
      sed -e '25i#include <QModelIndex>' -i src/gui/preferences/settingsabstractwidget.h
    '';

    # Makes digikam find some FindXXXX.cmake
    KDEDIRS="${qjson}";

    # Find kdepimlibs's upper case headers under `include/KDE`.
    NIX_CFLAGS_COMPILE = "-I${kdepimlibs}/include/KDE";

    # Helps digiKam find libusb, otherwise gphoto2 support is disabled
    cmakeFlags = [
      "-DLIBUSB_LIBRARIES=${libusb1}/lib"
      "-DLIBUSB_INCLUDE_DIR=${libusb1}/include/libusb-1.0"
      "-DENABLE_BALOOSUPPORT=ON"
      "-DENABLE_KDEPIMLIBSSUPPORT=ON"
      "-DENABLE_LCMS2=ON"
    ];

    enableParallelBuilding = true;
  };

  kdePkgs = [
    build # kbibtex's own build
    kdelibs kdepimlibs kde_runtime kde_baseapps libkdcraw oxygen_icons
    shared_mime_info okular
  ] ++ [
    # Optional build time dependencies
    kfilemetadata libkipi
  ] ++ [
    # Plugins optional build time dependencies
    libkvkontakte
  ];


  # TODO: It should be the responsability of these packages to add themselves to `KDEDIRS`. See
  # <https://github.com/ttuegel/nixpkgs/commit/a0efeacc0ef2cf63bbb768bfb172a483307d080b> for
  # a practical example.
  # IMPORTANT: Note that using `XDG_DATA_DIRS` here instead of `KDEDIRS` won't work properly.
  KDEDIRS = with stdenv.lib; concatStrings (intersperse ":" (map (x: "${x}") kdePkgs));

  sycocaDirRelPath = "var/lib/kdesycoca";
  sycocaFileRelPath = "${sycocaDirRelPath}/${pName}.sycoca";

  sycoca = runCommand "${pName}" {

    name = "kbibtex-sycoca-${version}";

    nativeBuildInputs = [ kdelibs ];

    dontPatchELF = true;
    dontStrip = true;

  } ''
    # Make sure kbuildsycoca4 does not attempt to write to user home directory.
    export HOME=$PWD
    export KDESYCOCA="$out/${sycocaFileRelPath}"
    mkdir -p $out/${sycocaDirRelPath}
    export XDG_DATA_DIRS=""
    export KDEDIRS="${KDEDIRS}"
    kbuildsycoca4 --noincremental --nosignal
  '';


  replaceExeListWithWrapped =
    let f = exeName: ''
        rm -f "$out/bin/${exeName}"
        makeWrapper "${build}/bin/${exeName}" "$out/bin/${exeName}" \
          --set XDG_DATA_DIRS "" \
          --set KDEDIRS "${KDEDIRS}" \
          --set KDESYCOCA "${sycoca}/${sycocaFileRelPath}"
      '';
    in
      with stdenv.lib; exeNameList: concatStrings (intersperse "\n" (map f exeNameList));

in


with stdenv.lib;

/*
  Final derivation
  ----------------
   -  Create symlinks to our original build derivation items.
   -  Wrap specific executables so that they know of the appropriate
      sycoca database, `KDEDIRS` to use and block any interference
      from `XDG_DATA_DIRS` (only `dnginfo` is not wrapped).
*/
runCommand "${pName}" {
  inherit build;
  inherit sycoca;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = kdePkgs;

  dontPatchELF = true;
  dontStrip = true;
} ''
  pushd $build > /dev/null
  for d in `find . -maxdepth 1 -name "*" -printf "%f\n" | tail -n+2`; do
    mkdir -p $out/$d
    for f in `find $d -maxdepth 1 -name "*" -printf "%f\n" | tail -n+2`; do
        ln -s "$build/$d/$f" "$out/$d/$f"
    done
  done
  popd > /dev/null

  ${replaceExeListWithWrapped [ "kbibtex" ]}
''
