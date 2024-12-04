#!/usr/bin/env bash
set -e

BASE=$(dirname "$(readlink -f "$0")")

export F="$BASE/test.nix"

[[ -e "$F" ]] || {
    echo "Couldn't find test.nix file '$F', aborting" 1>&2
    exit 1
}

if nix-build --show-trace --no-out-link -E '(import (builtins.getEnv "F") {})'
then
    echo "ok - nix-config tests"
else
    echo "not ok - nix-config tests"
    exit 1
fi

exit
