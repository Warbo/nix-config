self: super:
with self;

{
  fauxcon = stdenv.mkDerivation {
    name = "fauxcon";
    src  = fetchFromGitHub {
      owner  = "lornix";
      repo   = "fauxcon";
      rev    = "7d600cd";
      sha256 = "0bq5j812abxc432l5p5jnwrklqcpa389izzahc71x4mjpbwxzsn9";
    };

    installPhase = ''
      mkdir -p "$out/bin"
      cp fauxcon "$out/bin/"
    '';
  };
}
