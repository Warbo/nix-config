# Get the IPv4 address of s5.local, since many programs don't handle it
# resolving to an IPv6 address
set -e
if ADDRS=$(getent ahostsv4 s5.local)
then
    echo "$ADDRS" | head -n1 | awk '{print $1}'
else
    echo "Couldn't resolve IPv4 for s5.local" 1>&2
    exit 1
fi
