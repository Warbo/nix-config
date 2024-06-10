STORE_DIR="$1"
shift
bwrap \
    --unsetenv NIX_REMOTE \
    --dev-bind / / \
    --bind "$STORE_DIR" /nix \
    "$@"
