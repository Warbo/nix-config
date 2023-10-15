# Runs a given command, using aws-login to obtain an AWS access token.
# This avoids permanently storing credentials in plaintext.
AWS_LOGIN=$(command -v aws-login)

DIR=$(mktemp -d)
cleanup() {
    rm -rf "$DIR"
}
trap cleanup EXIT

export AWS_CONFIG_FILE="$DIR/config"
printf '[default]\ncredential_process=%s' "$AWS_LOGIN" > "$AWS_CONFIG_FILE"
"$@"
