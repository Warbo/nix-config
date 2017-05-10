{ cabal2nix, makeWrapper, runCommand, writeScript }:

# Provides a wrapper around cabal2nix, which caches expressions in /tmp
runCommand "cache-cabal2nix"
  {
    buildInputs = [ makeWrapper ];
    CACHEDIR    = "cache-cabal2nix-${cabal2nix.version}";
    raw         = writeScript "cache-cabal2nix" ''
      #!/usr/bin/env bash
      set -e

      [[ -d /tmp/"$CACHEDIR" ]] || {
        mkdir /tmp/"$CACHEDIR"
        chmod 777 /tmp/"$CACHEDIR"
      }

      if echo "$*" | grep '^cabal://' 1>/dev/null
      then
        # Use cache
         KEY=$(echo "$*" | tr '/' '_')
        FILE=/tmp/"$CACHEDIR"/"$KEY"

        if [[ -e "$FILE" ]]
        then
          cat "$FILE"
          exit 0
        fi

        # Generate from scratch
        RESULT=$(cabal2nix "$@")
        CODE="$?"
        if [[ -n "$RESULT" ]]
        then
          printf "$RESULT" > "$FILE"
          chmod +r "$FILE"
        fi

        exit "$CODE"
      fi

      # Don't cache (e.g. if it's a relative dir)
      cabal2nix "$@"
    '';
  }
  ''
    mkdir -p "$out/bin"
    makeWrapper "$raw" "$out/bin/cabal2nix" --prefix PATH : "${cabal2nix}/bin" \
                                            --set CACHEDIR "$CACHEDIR"
  ''
