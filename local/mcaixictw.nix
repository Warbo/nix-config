{ stdenv, fetchgit, haskellPackages }:

stdenv.mkDerivation {
  name = "mc-aixi-ctw";

  src = fetchgit {
    url = git://gitorious.org/mc-aixi-ctw/mc-aixi-ctw.git;
    rev = "e9452dd";
    sha256 = "10yhvvqlfh0vbn4bpgfwsxpbl89b32ngn2g5r2616pv1rrz32i2q";
  };

  #buildInputs = [];

  installPhase = ''
    mkdir -p "$out/bin"
    cp aixi "$out/bin/"
  '';
}
