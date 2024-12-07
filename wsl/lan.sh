#!/usr/bin/env bash
set -e
# VPN may add an extraneous route which hides our LAN. Remove it if found.
{
    ip route |
        grep '192\.168\.0\.' |
        grep 'via' |
        grep -v '^default' |
        cut -d' ' -f1-3 || true;
} | while read -r ROUTE
do
    echo "Removing route $ROUTE so we can access LAN" 1>&2
    # shellcheck disable=SC2086
    sudo ip route del $ROUTE
done

# Now we implement a poor man's mDNS. First we scan the local network for all of
# the active IP addresses.
RANGE=$(ip route |
            grep -o '^default via [0-9.]*' |
            cut -d' ' -f3 |
            cut -d. -f1-3)
export RANGE

dedupe() {
    # Like uniq but outputs unique lines immediately (uses O(n) memory though!)
    unset seen
    declare -A seen
    while IFS= read -r line
    do
        if [[ -z "${seen[$line]+_}" ]]
        then
            printf '%s\n' "$line"
            seen[$line]=1
        fi
    done
}

getIps() {
    # Use grep in line-buffered mode, so we can start processing entries without
    # having to wait for the scan to complete.
    {
        ip neighbour  # Fast, but only those we've already connected to
        sudo "$(command -v nmap)" -sn "$RANGE.0/24"  # Slow but does a full scan
    } | grep --line-buffered -o "$RANGE"'\.[0-9]*' | dedupe
}

# Next we attempt to SSH into them using some known usernames. We use BatchMode
# to avoid asking the user for a password; instead relying on an authorised key.

trySsh() {
    if timeout 33 ssh \
               -o BatchMode=yes \
               -o StrictHostKeyChecking=no \
               -o ConnectTimeout=30 \
               "$1" true 1>&2
    then
        echo "Connected to $1" 1>&2
        echo "$1"
    else
        return
    fi
    return
}
export -f trySsh

workingLogins() {
    # Try each SSH connection concurrently
    while read -r H
    do
        for U in chris manjaro user
        do
            printf '%s@%s\n' "$U" "$H"
        done
    done | SHELL=$(type -p bash) parallel --will-cite 'trySsh {}'
}

# Once we have some working logins, we can look up some .local domains

findNameCmds() {
    # Output a command that will get the (remote) system's hostname and IP. We
    # append '.local' to the name, and select only those address in RANGE (we
    # can't rely on getent for localhost, since it can give us an IP for any of
    # the networks we're connected to!)
    # shellcheck disable=SC2016
    printf '{ %s; } | xargs -L1 printf "%s" "$(%s)"\n' \
           'hostname 2>/dev/null || hostnamectl hostname || true' \
           '%s STREAM %s.local\n' \
           'ip address | grep -o "'"$RANGE"'.[0-9]*/" | sed -e "s@/@@g"'
    # Output a command to look up each .local domain in our current /etc/hosts
    < /etc/hosts grep -v '^#' |
        awk '{print $2}' |
        grep '\.local' |
        sed -e 's/^\(.*\)$/getent ahostsv4 \1/g'
    # Output a command that will do an mDNS scan with Avahi, and look up the IP
    # address of each "workstation" it finds
    # shellcheck disable=SC2016
    printf '{ %s | %s | %s | %s; } | xargs -L1 getent ahostsv4\n' \
           'avahi-browse -at' \
           'grep --line-buffered "_workstation"' \
           'awk '\''{printf $4".local\n"}'\' \
           'uniq'
}
export -f findNameCmds

lookupNames() {
    # Use each working SSH login (concurrently) to look up mDNS names
    SHELL=$(type -p bash) parallel --will-cite --line-buffer \
         'findNameCmds | ssh \
           -o BatchMode=yes \
           -o StrictHostKeyChecking=no \
           {} sh' || true
}

# Finally we update the entries in /etc/hosts with the corresponding IPs
updateHosts() {
    # The input will be the output of many 'getentahostsv4' invocations. Dedupe
    # them, and update /etc/hosts with each IP/name pair. Note that this is done
    # sequentially, to ensure we won't have conflicting writes to that file.
    grep --line-buffered 'STREAM' |
        grep --line-buffered  "$RANGE" |
        dedupe |
        while read -r entry
    do
        ip=$(echo "$entry" | awk '{print $1}')
        name=$(echo "$entry" | awk '{print $3}')
        if grep -q "$name" < /etc/hosts
        then
            echo "Updating $name to $ip in /etc/hosts" 1>&2
            sudo sed -e "s/^[0-9.]* *$name/$ip $name/g" -i /etc/hosts
        else
            echo "Adding $name as $ip to /etc/hosts" 1>&2
            {
                echo
                echo "$ip $name"
            } | sudo tee -a /etc/hosts > /dev/null
        fi
    done
}

echo "Scanning for machines on LAN..." 1>&2
getIps | workingLogins | lookupNames | dedupe | updateHosts
