# Plugs our Pinephone configuration.nix into mobile-nixos. We allow mobile-nixos
# to use its own Nixpkgs, to minimise breakage.
# NOTE: This defines a disk image to boot from microSD. Once we've got a system
# up and running, we can just use configuration.nix like normal.
# NOTE: This will either build natively or cross-compile, depending on the value
# of currentSystem. However, some packages don't cross-compile properly; e.g. Qt
# may end up with two versions, then complain. To avoid that, comment-out the
# relevant options in configuration.nix to get a minimal image that will boot on
# a Pinephone, then build the rest natively on that.
with {
  inherit ((rec {
    inherit (import ../../overrides/nix-helpers.nix overrides { }) overrides;
  }).overrides) nix-helpers;
};
{ configuration ? ./configuration.nix
, device ? "pine64-pinephone"
, mobile-nixos ? import ./mobile-nixos.nix
, attrPath ? [ "outputs" "disk-image" ]
, uboot ? ./u-boot-sunxi-with-spl-528.bin
}:
with rec {
  configured = import mobile-nixos { inherit configuration device; };

  get = with builtins; path: x:
    if path == [] then x else get (tail path) (getAttr (head path) x);

  image = get attrPath configured;

  ubootable = nix-helpers.nixpkgs.runCommand "${image.name}-ubootable"
    { inherit image uboot; }
    ''
      for IMG in "$image"/*.img
      do
        mkdir "$out"
        OLD=$(basename "$IMG" .img)
        NEW="$out/$OLD-ubootable.img"
        cp "$IMG" "$NEW"
        chmod +w "$NEW"

        # We need to overwrite some of the image with UBoot, so the microSD can
        # boot on a stock Pinephone's UBoot (i.e. without having TowBoot).
        # There's 1MiB of wiggle room at the start of the image, but some of
        # that is used for a "protective MBR" and other things. UBoot is about
        # 740K. Writing with an offset (via seek) of:
        #  - 8: boots the card's UBoot, but stalls at Stage1 due to a corrupted
        #       partition table.
        #  - 64: doesn't corrupt the parition table; but doesn't boot the card.
        #  - 128: boots the card, and doesn't corrput the partitions. Success!
        dd if="$uboot" of="$NEW" bs=1024 seek=128 conv=notrunc
        break
      done
    '';
};
if uboot == null
then image
else ubootable
