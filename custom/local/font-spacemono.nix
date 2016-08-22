{ latestGit, stdenv }:
stdenv.mkDerivation {
  name = "font-spacemono";
  src  = latestGit {
    url = https://github.com/googlefonts/spacemono.git;
  };
  buildCommand = ''
    source $stdenv/setup

    mkdir -p "$out/share"
    cp -r "$src/fonts" "$out/share"
  '';
}
