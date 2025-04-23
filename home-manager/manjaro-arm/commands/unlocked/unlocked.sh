#!/usr/bin/env bash
set -eu

# Print "keyring FOO", "ssh BAR" and/or "gpg BAZ" when those things are unlocked

busctl --user tree org.freedesktop.secrets --list |
    grep -o '/org/freedesktop/secrets/collection/[^/]*keyring' |
    uniq |
    while read -r KEYRING
    do
        if busctl --user get-property org.freedesktop.secrets \
               "$KEYRING" \
               org.freedesktop.Secret.Collection Locked | grep -q 'true'
        then
            true
        else
            echo "keyring $KEYRING"
        fi
    done

ssh-add -L | while read -r PUBKEY
do
    for F in ~/.ssh/*.pub
    do
        PUBF=$(cat "$F")
        if [[ "$PUBKEY" = "$PUBF" ]]
        then
            echo "ssh $(dirname "$F")/$(basename "$F" .pub)"
        fi
    done
done

EMAIL=$(git config --get user.email)
gpg --fingerprint --with-keygrip "$EMAIL" |
    grep -i 'keygrip =' |
    sed 's/^ *[Kk]eygrip = //g' |
    while read -r KEYGRIP
    do
        echo "KEYINFO --no-ask $KEYGRIP Err Pmt Des" |
            gpg-connect-agent |
            grep 'KEYINFO'
    done |
    while read -r GPGLINE
    do
        CACHED=$(echo "$GPGLINE" | cut -d' ' -f7)
        if [[ "$CACHED" = "1" ]]
        then
            echo "gpg $EMAIL"
        fi
    done |
    uniq
