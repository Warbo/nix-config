#!?usr/bin/env bash

# This is sourced by /bin/pinentry (at least on Manjaro) before it picks between
# pinentry-gtk-2 and pinentry-curses. We make our own choice instead, and use
# exec to avoid taking any further actions.

# We prefer tty over curses, since curses can break Emacs shell-mode, etc. There
# is pinentry-emacs, but introducing a third possibility doesn't seem worth it.
PINENTRY_TERMINAL=$(command -v pinentry-tty) || true

# Check if we're running from a GUI
SESSION="${XDG_SESSION_TYPE:-}"
if [[ "$SESSION" = 'x11' ]] || [[ "$SESSION" = 'wayland' ]]
then
    # Seems like it, look for a nice GUI pinentry
    for GUI in pinentry-qt pinentry-gtk-2 pinentry-gnome3
    do
        # Skip if we don't have this command
        FOUND=$(command -v "$GUI") || continue

        # Skip if the command doesn't work: it should print "OK" on stdout, but
        # may fail due to missing libraries (silly Manjaro...)
        echo "" | "$FOUND" | grep -q "OK" || continue

        PINENTRY_GUI="$FOUND"
        break
    done
    [[ -n "$PINENTRY_GUI" ]] && exec "$PINENTRY_GUI" "$@"
fi

# If we're here then either we're not on a GUI, or we couldn't find a working
# GUI pinentry program. Either way, use a terminal one.
exec "$PINENTRY_TERMINAL" "$@"
