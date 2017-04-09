{ cacert, git, go, runCommand }:

runCommand "goat"
  {
    buildInputs    = [ git go ];
    GIT_SSL_CAINFO = "${cacert}/etc/ssl/certs/ca-bundle.crt";
  }
  ''
    mkdir "$out"
    cd "$out"

    export GOPATH="$PWD"
    go get github.com/blampe/goat
  ''
