{ python3, writeScript, writeShellApplication }:

with {
  askpass = writeScript "askpass.sh" ''
    #!/usr/bin/env bash
    exec cat
  '';
};
writeShellApplication {
  name = "unlock";
  runtimeInputs = [ (python3.withPackages (p: [ p.secretstorage ])) ];
  text = ''
    set -eu
    echo "Unlocking keyrings" 1>&2
    python3 ${./unlock.py}
    SSH_FILE="$HOME/.ssh/id_rsa"
    echo "Adding $SSH_FILE to agent" 1>&2
    # See https://stackoverflow.com/a/65400796 for why we're invoking ssh-add
    # using SSH_ASKPASS and setsid.
    # We send stderr through sed to avoid Emacs spotting the passphrase prompt.
    secret-tool lookup unique "ssh-store:$SSH_FILE" |
      SSH_ASKPASS=${askpass} \
      SSH_ASKPASS_REQUIRE=force \
        setsid -w ssh-add "$SSH_FILE" 2> >(sed -e 's/Enter/Reading/g' 1>&2)
  '';
}
