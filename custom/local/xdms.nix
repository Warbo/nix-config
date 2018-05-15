{ stdenv, fetchurl, hasBinary, lhasa, gnumake, withDeps }:

with rec {
  pkg = stdenv.mkDerivation {
    name = "xdms";

    src = fetchurl {
      url    = http://aminet.net/util/arc/xDMS.lha;
      sha256 = "0f1fs9nlcqggix5iziadk5qc2pqxx6wsm0ixd9hdncvrygs67ffq";
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
    '';
  };

  tested = withDeps [ (hasBinary pkg "xdms") ] pkg;
};
{
  pkg   =   tested;
  tests = [ tested ];
}
