{ stdenv, fetchurl, lhasa, gnumake }:

stdenv.mkDerivation {
  name = "xdms";

  src = fetchurl {
    url = http://aminet.net/util/arc/xDMS.lha;
    sha256 = "0f1fs9nlcqggix5iziadk5qc2pqxx6wsm0ixd9hdncvrygs67ffq";
    #url = http://zakalwe.fi/~shd/foss/xdms/xdms-1.3.2.tar.bz2;
    #sha256 = "0zplagy96m9sxfhjx2rqyx2b2zxqc6wsg3iknhjs58yn5pqc8zin";
  };

  buildInputs = [ lhasa gnumake ];

  unpackPhase = ''
    lha x /nix/store/hhihia6jr25l4wwrf0g6yhdr743nlywn-xDMS.lha
  '';

  buildPhase = ''
    cd xdms/src
    make
  '';

  installPhase = ''
    cd ..
    mkdir -p "$out/bin"
    cp src/xdms "$out/bin"
    cp Linux-bin/readdisk "$out/bin"
    #cp Linux-bin/xdms "$out/bin"
  '';
}
