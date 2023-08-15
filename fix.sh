#!/usr/bin/env bash
set -ex

# Attempt to fix our external monitor setup, by turning things off and on again.
# This script can be run manually, e.g. if the display goes wonky, and it also
# has an associated 'fix-monitor.service' in systemd. The latter gets triggered
# by an associated udev rule '95-monitor-hotplug.rules' (which should be
# symlinked into /etc/udev/rules.d/) which triggers whenever the PinePhone's
# graphics card changes (card1; since card0 is 'virtual'). We need to use this
# two-step udev -> systemd approach, since this script takes too long to run as
# a udev handler directly.

# NOTE: This uses wlr-randr, which only works for compositors implementing the
# associated wlroots protocol. This works on Phosh, but not on KWin; but that's
# fine since KWin handles monitor plugging/unplugging correctly anyway!

# Since this script may be run by systemd, we can't assume it's run manjaro's
# Bash profile; hence we add .nix-profile to PATH ourselves.
export PATH="/home/manjaro/.nix-profile/bin:$PATH"

# Set fallback env vars, in case we're being run from systemd
XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)/}"
WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
DISPLAY="${DISPLAY:-:0}"

# Bring home-wifi-connected.target up or down, as appropriate
/home/manjaro/.manjaro_fixes/dispatcher.d/95-home.sh || true

# Udev can trigger this script 'too quickly', before new monitors appear in the
# wlr-randr output. This 'sleep' statement is a lazy way to work around it!
sleep 5

# Now we've slept, the randr outputs should be up to date. Check whether our
# monitor is plugged in: if so, set up our desktop nicely; otherwise leave the
# monitor configuration up to the DE.
if wlr-randr | grep -q 'Dell Inc. DELL U2419H 48Z6TS2 (HDMI-A-1)'
then
    # Monitor found. Turn it on (in portrait mode, and scaled nicely)

    # If the monitor's glitched we'll need to "turn it off and on again", by
    # switching to some other setup and back. Changing the monitor resolution
    # causes some applications to misbehave (e.g. Firefox changes DPI wildly),
    # so we only use a different *refresh rate*. We also turn the phone screen
    # on and off, to try and avoid mirrored sections of the screen disappearing!
    wlr-randr --output DSI-1 --on
    sleep 1
    wlr-randr --output HDMI-A-1 --on \
              --mode 1920x1080@60 \
              --transform 270 \
              --scale 1.0
    sleep 1

    # Now set the config we want; only monitor on, since GPU struggles with both
    wlr-randr --output DSI-1 --off
    sleep 1
    wlr-randr --output HDMI-A-1 --on \
              --mode 1920x1080@50 \
              --transform 270 \
              --scale 1.0

    # Turn down the font scaling to fit more on screen (since it's not dinky,
    # and we're not jabbing it with our fat fingers)
    gsettings set org.gnome.desktop.interface text-scaling-factor '0.75' || true
else
    # If we're not on our known desktop setup, then crank the font scaling back
    # up (for legibility on a small screen in the sun, and to make buttons large
    # enough to hit via the capacitive touchscreen)
    gsettings set org.gnome.desktop.interface text-scaling-factor '1.33' || true
fi
