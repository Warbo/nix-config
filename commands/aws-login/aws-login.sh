set -e

# Creates a temporary folder for AWS credentials, populates it using
# secrets taken from the Pass database, and gets a temporary session
# token from AWS. This way, the only permanent way our credentials are
# stored is in Pass's encrypted database; and applications are only
# exposed to temporary tokens, rather than the underlying secrets.

DIR=$(mktemp -d)
cleanup() {
  rm -rf "$DIR"
}
trap cleanup EXIT

export AWS_SHARED_CREDENTIALS_FILE="$DIR/creds"

CREDS=$(pass automation/aws_s3 | sed -e 's@//.*@@g')
echo "$CREDS" | jq -r '[
  "[default]\naws_access_key_id=",
  .AccessKeyId,
  "\naws_secret_access_key=",
  .SecretAccessKey,
  "\n"
] | join("")' > "$AWS_SHARED_CREDENTIALS_FILE"

aws sts get-session-token --output json --query \
  'Credentials.[AccessKeyId,SecretAccessKey,SessionToken,Expiration]' |
  jq '{
    "Version": 1,
    "AccessKeyId": .[0],
    "SecretAccessKey": .[1],
    "SessionToken": .[2],
    "Expiration": .[3]
  }'
