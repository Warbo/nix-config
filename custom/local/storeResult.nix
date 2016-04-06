{ writeScript }:

# A script we can embed in others. Adds its first arg to the Nix store, and
# writes the resulting path to the second arg. This avoids newline issues.
writeScript "store-result" ''
  set -e
  RESULT=$(nix-store --add "$1")
  printf '%s' "$RESULT" > "$out"
''
