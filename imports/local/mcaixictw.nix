{ stdenv, latestGit, haskellPackages }:

stdenv.mkDerivation {
  name = "mc-aixi-ctw";

  src = latestGit { url = http://chriswarbo.net/git/mc-aixi-ctw.git; };

  installPhase = ''
    mkdir -p "$out/bin"
    cp aixi "$out/bin/"
  '';
}
