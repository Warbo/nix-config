DISK_ID='804f4826-e4b2-4e06-9759-1628da22b787'
DISK_LABEL='internal'
DISK_ROOT="/home/manjaro/Drives/uuids/$DISK_ID"
UNION_DIR="/home/manjaro/Drives/unions/ssd_store_overlay"

[[ -e "/dev/disk/by-uuid/$DISK_ID" ]] || {
  echo "SSD partition $DISK_ID (labelled '$DISK_LABEL') not present"
  exit 1
} 1>&2

DEVICE=$(readlink -f "/dev/disk/by-uuid/$DISK_ID")
[[ -e "/dev/disk/by-label/$DISK_LABEL" ]] || {
  echo "Found SSD partition $DISK_ID, but not label '$DISK_LABEL'"
  exit 1
} 1>&2
GOT=$(readlink -f "/dev/disk/by-label/$DISK_LABEL")
[[ "$DEVICE" = "$GOT" ]] || {
  echo "UUID $DISK_ID is $DEVICE but label $DISK_LABEL is $GOT"
  exit 1
} 1>&2

mkdir -p "$DISK_ROOT"
mount | grep -q "$DISK_ROOT" || sudo mount "$DEVICE" "$DISK_ROOT"

# Use mergerfs to combine our normal /nix with the SSD's /nix. We do this
# with three layers:
#  - Start with SSD's /nix, read-only. This sets the permissions, so our
#    normal user can write to /nix/store.
#  - Overlay /nix, read only. This gives us aarch64 binaries, etc.
#  - Overlay SSD's /nix again, but read/write. This ensures all writes go
#    to the SSD, so we don't run out of space on /.
mkdir -p "$UNION_DIR"
mount | grep -q "$UNION_DIR" ||
  mergerfs \
    -o category.create=mfs -o nonempty -o allow_other \
      "$DISK_ROOT/nix=RO:/nix=RO:$DISK_ROOT/nix" \
      "$UNION_DIR"

# Run with-nix-store to enter a chroot with $UNION_DIR bind-mounted over
# /nix. We also do the following, for a smoother experience:
#  - Use SSD's /nix/var instead of the union. This ensures our user can
#    write to the DB, that we aren't filling our /nix DB with ephemeral
#    entries, that we can create gc-roots, etc.
#  - Replace /nix/var/nix/daemon-socket with a tmpfs, so it appears as an
#    empty directory rather than containing a socket; which prevents Nix
#    commands trying to connect to a daemon.
#  - Replace /nix/var/nix/profiles with a tmpfs so our user has permission
#    to chmod its contents.
#  - Bind-mount our default profile in /nix/var/nix/profiles, so our $PATH
#    will contain Nix binaries for aarch64.
#  - Bind-mount our user's profile in /nix/var/nix/profiles, so our Bash
#    startup script can find home-manager variables, etc.
DEF_PROFILE=/nix/var/nix/profiles/default
USER_PROFILE="/nix/var/nix/profiles/per-user/$USER/profile"
with-nix-store \
  "$UNION_DIR" \
  --bind "$DISK_ROOT/nix/var" /nix/var \
  --tmpfs /nix/var/nix/daemon-socket \
  --tmpfs /nix/var/nix/profiles \
  --bind "$(readlink -f "$DEF_PROFILE")" "$DEF_PROFILE" \
  --bind "$USER_PROFILE" "$USER_PROFILE" \
  "$@"
