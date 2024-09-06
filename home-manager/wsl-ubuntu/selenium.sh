#!/usr/bin/env bash

fail() { echo "$*" 1>&2; exit 1; }

set +eu
# shellcheck source=/dev/null
. "${SETUP:?SETUP is not set}"
set -eu

echo "Building container image" 1>&2
IMAGE_FILE=$(nix build --print-out-paths \
  -f "${SELENIUM_CONTAINER_NIX_DEF:?SELENIUM_CONTAINER_NIX_DEF not set}")

[[ -n "$IMAGE_FILE" ]] || fail 'Did not find path for image file'
echo "Loading '$IMAGE_FILE' into Podman" 1>&2
LOADED=$(podman load < "$IMAGE_FILE")
[[ -n "$LOADED" ]] || fail "Got no output when loading '$IMAGE_FILE'"

IMAGE_NAME=$(echo "$LOADED" | grep 'Loaded image:' | cut -d' ' -f3)
[[ -n "$IMAGE_NAME" ]] || fail "Did not find image name in '$LOADED'"

# Spot any args beginning with 'SeleniumTests.', so we can pass them as a filter
# to the 'selenium-tests' command.
TEST_COUNT=0
for ARG in "$@"
do
  if printf '%s' "$ARG" | grep -q '^SeleniumTests\.'
  then
    (( TEST_COUNT += 1 ))
  fi
done

PODMAN_ARGS=()
if [[ "$#" -eq 0 ]]
then
  echo "No args given, starting an interactive shell"
  PODMAN_ARGS+=('-it' "$IMAGE_NAME")
else
  if [[ "$TEST_COUNT" -eq "$#" ]]
  then
    echo "All args look like Selenium test names; running them directly"
    TEST_ARGS=()
    for ARG in "$@"
    do
        TEST_ARGS+=('-m' "$ARG")
    done
    PODMAN_ARGS+=('--env' "ARGS=${TEST_ARGS[*]}" "$IMAGE_NAME" 'selenium-test')
    unset TEST_ARGS
  else
    echo "Some args aren't SeleniumTests, passing them to podman"
    USES_IMAGE=0
    for ARG in "$@"
    do
      if [[ "$ARG" = 'IMAGE_NAME' ]]
      then
        echo "Replacing 'IMAGE_NAME' with '$IMAGE_NAME'"
        PODMAN_ARGS+=("$IMAGE_NAME")
        USES_IMAGE=1
      else
        if printf '%s' "$ARG" | grep -q '^_[_]*IMAGE_NAME$'
        then
          echo "Replacing '$ARG' with '${ARG:1}'"
          PODMAN_ARGS+=("${ARG:1}")
        fi
      fi
    done
    if [[ "$USES_IMAGE" -eq 0 ]]
    then
      echo "WARNING: Generated the command 'podman run ${PODMAN_ARGS[*]}',"
      echo "without using the generated image name (which is '$IMAGE_NAME')."
      echo "To use the generated image name, either:"
      echo
      echo " - Run with no arguments (for an interactive shell)"
      echo " - Run with only 'SeleniumTests.*' arguments, to just test those"
      echo " - Use the argument 'IMAGE_NAME' as a placeholder to be replaced"
      echo
      echo "Note that, in the unlikely case that an argument needs to be the"
      echo "literal string 'IMAGE_NAME', it can be given as '_IMAGE_NAME': this"
      echo "script will drop the first character of arguments which consist"
      echo "solely of 'IMAGE_NAME' prefixed by at least one underscore (this"
      echo "way, we can use '__IMAGE_NAME' for a literal '_IMAGE_NAME', etc.)"
    fi
  fi
fi 1>&2

exec podman run "${PODMAN_ARGS[@]}"
