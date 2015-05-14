{ stdenv, fetchgit }:

stdenv.mkDerivation {
  name = "hydra";

  src = fetchgit {
    url = https://github.com/NixOS/hydra.git;
    rev = "e003665146";
    sha256 = "0xkqgdq909a7csq86ljw12dw1m7922il97fg407dyc6vw3rd2mcx";
  };

  installPhase = ''
    mkdir -p "$out/lib/hydra"
    cp -r * "$out/lib/hydra/"
  '';
}
