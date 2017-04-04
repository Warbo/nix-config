{ buildEnv, cacert, go, git, runCommand }:

with rec {

goGet = name: pre: runCommand "go-get"
  {
    buildInputs = [ go git ];
    GIT_SSL_CAINFO = "${cacert}/etc/ssl/certs/ca-bundle.crt";
  }
  ''
    ${pre}
    GOPATH="$PWD" go get ${name}

    mkdir -p "$out"
    cp -r ./bin "$out"/
  '';

e = goGet "github.com/whyrusleeping/elcid" ''
  GOPATH="$PWD" go get github.com/whyrusleeping/elcid || true
  pushd src/github.com/whyrusleeping/elcid
    git checkout "9bcd412e289dae0e2d7b7039a1be33c5bc24ab38"
  popd
'';

b = goGet "github.com/whyrusleeping/bases" "";

};
buildEnv { name = "elcid"; paths = [ e b ]; }
