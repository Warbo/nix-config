{ latestGit, stdenv }:
stdenv.mkDerivation {
  name = "font-spacemono";
  src  = latestGit {
    url    = https://github.com/googlefonts/spacemono.git;
    stable = {
      rev    = "f5ebc1e";
      sha256 = "1xx2xjxb9nfksy0s1md1vxrs86nn83qzkkc5c8b0k4aj5w1bijmk";
    };
  };
  buildCommand = ''
    source $stdenv/setup

    mkdir -p "$out/share"
    cp -r "$src/fonts" "$out/share"
  '';
}
