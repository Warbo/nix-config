# From https://gist.github.com/WillianTomaz/a972f544cc201d3fbc8cd1f6aeccef51
mkdir -p "$(dirname "$SSH_AUTH_SOCK")"
ps -auxww | grep -q "[n]piperelay.exe -ei -s //./pipe/openssh-ssh-agent" || {
    rm -f "$SSH_AUTH_SOCK"
    echo "Starting SSH-Agent relay..." 1>&2
    # setsid to force new session to keep running
    # set socat to listen on $SSH_AUTH_SOCK and forward to npiperelay which then
    # forwards to openssh-ssh-agent on windows
    (setsid socat \
            "UNIX-LISTEN:$SSH_AUTH_SOCK,fork" \
            "EXEC:npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) \
        >/dev/null 2>&1
}
