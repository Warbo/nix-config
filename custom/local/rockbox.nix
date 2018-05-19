{ buildEnv, fetchurl, hasBinary, libusb1, patchelf, rockbox_utility, stdenv,
  withDeps, writeScript }:

with rec {
  firmware = fetchurl {
    url    = https://files.freemyipod.org/~user890104/bootloader-ipodclassic-v1_0/bootloader-ipod6g.ipod;
    sha256 = "0xi1f7zp9ziq1iymv7fxnc5gca03j3hgy80p8w4sbj3fnib8x8fm";
  };

  firmware_script = writeScript "rockbox_6thgen_firmware" ''
    #!/usr/bin/env bash
    set -e
    mks5lboot --bl-inst ${firmware}
  '';

    scan_script = writeScript "rockbox_6thgen_scan" ''
    #!/usr/bin/env bash
    set -e
    echo "Scanning for iPod in firmware update mode (Ctrl-C when found)" 1>&2
    mks5lboot --dfuscan -l
  '';

  flasher = stdenv.mkDerivation {
    inherit firmware_script libusb1 scan_script;
    inherit (stdenv) glibc;
    name = "rockbox-6thgen-classic-bootloader-installer";
    src = fetchurl {
      url    = "https://files.freemyipod.org/~user890104/bootloader-ipodclassic-v1_0/Linux/mks5lboot.x86";
      sha256 = "1g7nyqz8gnc1q0hxm3pik2wqpiki457zhcqdm0h6674ns2z35m30";
    };
    unpackPhase = "true";
    buildInputs = [ patchelf ];
    shellHook   = ''
      echo "$msg"
    '';
    msg = ''
      RockBox bootloader installer for iPod Classic 6th generation. This was
      made on 2017-10-20, there may be an easier way to install RockBox now
      (e.g. if 6th gen classic has become an official port), so check!

      If not, then follow the instructions at:
        https://files.freemyipod.org/~user890104/bootloader-ipodclassic.html

      In particular:
       - Install RockBox first, as root, using its installer utility (without
         installing the bootloader)
       - Run `mks5lboot --dfuscan -l` (AKA `rockbox_6thgen_scan`)
       - Put iPod in firmware update mode
       - Run `mks5lboot --bl-inst ${firmware}` (AKA `rockbox_6thgen_firmware`)
    '';
    installPhase = ''
      set -e
      mkdir -p "$out/bin"
      NAME="$out/bin/mks5lboot"

      cp "$src" bin
      chmod +x  bin
      chmod +w  bin
      patchelf --set-interpreter "$glibc/lib/ld-linux.so.2" bin
      patchelf --set-rpath "$glibc/lib":"$libusb1/lib"      bin

      cp bin "$out/bin/mks5lboot"
      cp "$firmware_script" "$out/bin/rockbox_6thgen_firmware"
      cp "$scan_script"     "$out/bin/rockbox_6thgen_scan"
    '';
  };

  pkg = buildEnv {
    name  = "rockbox-utils";
    paths = [ flasher rockbox_utility ];
  };

  tested = withDeps [ (hasBinary pkg "mks5lboot") ] pkg;
};
{
  pkg   =   tested;
  tests = [ tested ];
}
