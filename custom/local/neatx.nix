{ fetchurl, stdenv, unzip }:

stdenv.mkDerivation {
  name = "neatx";
  buildInputs = [ unzip ];
  src = fetchurl {
    url = "https://storage.googleapis.com/google-code-archive-source/v2/code.google.com/neatx/source-archive.zip";
    sha256 = "15d8nax0xrzxmf4hx8lwyykqm0fpa7yi1zf1l8aj9zg56v8f5zq5";
  };
}
