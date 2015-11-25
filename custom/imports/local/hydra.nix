{ stdenv, latestGit }:

stdenv.mkDerivation {
  name = "hydra";

  src = latestGit { url = https://github.com/NixOS/hydra.git; };

  installPhase = ''
    mkdir -p "$out/lib/hydra"
    cp -r * "$out/lib/hydra/"
  '';
}
