#!/usr/bin/env bash
set -e
FNT="${1:?Error: Need to pass a font string as argument, like '-jmk-neep-...'}"
if { timeout 0.5 xfontsel -fn "$FNT" || true; } 2>&1 |
       grep -q 'Warning: Cannot convert string'
then
    {
        echo "Font '$FNT' not available in the X server."
        echo "This can sometimes happen on WSL after suspending, unplugging an"
        echo "external monitor, etc."
        echo "Disconnecting/reconnecting an instance isn't enough to fix it,"
        echo "you'll need to restart it fully using 'wsl --shutdown'."
        echo "If that's not enough, try messing with fontconfig stuff, and if"
        echo "that fixes it for you then update '$0' to include it!"
    } 1>&2
    exit 1
else
    exit 0
fi
