{ bash, buildEnv, gnome, gobjectIntrospection, fetchFromGitHub, makeWrapper,
  python3Packages, runCommand, stdenv }:

with {
  env = buildEnv {
    name  = "revolt-env";
    paths = [
      python3Packages.python
      python3Packages.pygobject3
      gobjectIntrospection
    ];
  };
};
stdenv.mkDerivation {
  name = "revolt";
  src  = fetchFromGitHub {
    owner  = "aperezdc";
    repo   = "revolt";
    rev    = "04bf4b5";
    sha256 = "1sairjhm1j98kn9sqjqrf4p93vv71rddz1gxvc4bv195mjrmvnxj";
  };
  buildInputs  = [
    makeWrapper
    env
    (runCommand "fake-icon" {} ''
      mkdir -p "$out/bin"
      for F in gtk-update-icon-cache glib-compile-resources
      do
        echo -e "#!/usr/bin/env bash\ntrue" > "$out/bin/$F"
        chmod +x "$out/bin/$F"
      done
    '')
  ];
  patchPhase   = ''
    sed -e 's@/bin/bash@${bash}/bin/bash@g' -i install.sh
  '';
  installPhase = ''
    cat install-functions.sh
    mkdir -p "$out"
    bash -x ./install.sh --prefix="$out"
    for F in "$out/bin"/*
    do
      wrapProgram "$F" --prefix PATH : "${env}/bin"
    done
  '';
}
