self: super:

with self;

{

# A script we can embed in others. Adds its first arg to the Nix store, and
# writes the resulting path to the second arg. This avoids newline issues.
# Make sure `nix` is in your buildInputs (or equivalent), and the relevant
# environment variables are set.
storeResult = writeScript "store-result" ''
  set -e
  RESULT=$(nix-store --add "$1")
  printf '%s' "$RESULT" > "$out"
'';

}
